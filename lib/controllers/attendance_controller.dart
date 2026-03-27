import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../services/dashboard_service.dart';
import '../services/web_auth_service.dart';

class AttendanceController extends GetxController {
  late DashboardService _dashboardService;
  late WebAuthService _authService;

  final RxList<AttendanceModel> records = <AttendanceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  late Rx<DateTime> fromDate;
  late Rx<DateTime> toDate;

  // Pagination
  final RxInt currentPage = 0.obs;
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _dashboardService = Get.find<DashboardService>();
    _authService = Get.find<WebAuthService>();

    toDate = DateTime.now().obs;
    fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;

    loadRecords();
  }

  Future<void> loadRecords() async {
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _dashboardService.fetchAttendanceRecords(
        companyId,
        from: fromDate.value,
        to: toDate.value,
      );
      records.value = data;
      currentPage.value = 0;
    } catch (e) {
      errorMessage.value = 'Failed to load attendance records: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilter(DateTime from, DateTime to) async {
    fromDate.value = from;
    toDate.value = to;
    await loadRecords();
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  List<AttendanceModel> get paginatedRecords {
    final all = records;
    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  int get totalPages =>
      (records.length / pageSize).ceil().clamp(1, 9999);

  bool get hasPrevPage => currentPage.value > 0;
  bool get hasNextPage => currentPage.value < totalPages - 1;

  void nextPage() {
    if (hasNextPage) currentPage.value++;
  }

  void prevPage() {
    if (hasPrevPage) currentPage.value--;
  }

  // ── Computed stats ─────────────────────────────────────────────────────────

  int get presentCount =>
      records.where((r) => r.status == AttendanceStatus.present).length;

  int get lateCount =>
      records.where((r) => r.status == AttendanceStatus.late).length;

  int get absentCount =>
      records.where((r) => r.status == AttendanceStatus.absent).length;

  // ── CSV Export ─────────────────────────────────────────────────────────────

  void exportCsv() {
    final fmt = DateFormat('yyyy-MM-dd');
    final timeFmt = DateFormat('hh:mm a');

    final buffer = StringBuffer();
    // Header
    buffer.writeln(
      'Date,Employee Name,Employee ID,Check In,Check Out,'
      'Break Duration (min),Working Hours,Status',
    );

    for (final r in records) {
      final date = fmt.format(r.date);
      final name = _csvSafe(r.employeeName ?? '');
      final empId = _csvSafe(r.employeeId ?? '');
      final checkIn =
          r.checkInTime != null ? timeFmt.format(r.checkInTime!) : '-';
      final checkOut =
          r.checkOutTime != null ? timeFmt.format(r.checkOutTime!) : '-';
      final breakMin = r.breakDuration.inMinutes.toString();
      final workHrs = _durationToHours(r.workingDuration);
      final status = r.statusLabel;

      buffer.writeln(
        '$date,$name,$empId,$checkIn,$checkOut,$breakMin,$workHrs,$status',
      );
    }

    final csvString = buffer.toString();
    final bytes = utf8.encode(csvString);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final fileName =
        'attendance_${fmt.format(fromDate.value)}_to_${fmt.format(toDate.value)}.csv';

    // ignore: unused_local_variable
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  String _csvSafe(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _durationToHours(Duration d) {
    if (d.inSeconds <= 0) return '-';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  Future<void> refresh() => loadRecords();
}
