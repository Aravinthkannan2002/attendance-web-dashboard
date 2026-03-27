import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_service.dart';
import '../services/web_auth_service.dart';

class ReportsController extends GetxController {
  late DashboardService _dashboardService;
  late WebAuthService _authService;

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxList<EmployeeReport> employeeReports = <EmployeeReport>[].obs;

  @override
  void onInit() {
    super.onInit();
    _dashboardService = Get.find<DashboardService>();
    _authService = Get.find<WebAuthService>();
    loadReport();
  }

  int get totalWorkDays {
    final m = selectedMonth.value;
    final start = DateTime(m.year, m.month, 1);
    final end = DateTime(m.year, m.month + 1, 0);
    int count = 0;
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      if (d.weekday <= 5) count++;
    }
    return count;
  }

  double get avgAttendanceRate {
    if (employeeReports.isEmpty) return 0;
    final sum = employeeReports.fold<double>(0, (s, r) => s + r.attendanceRate);
    return sum / employeeReports.length;
  }

  int get totalLate =>
      employeeReports.fold<int>(0, (s, r) => s + r.lateDays);

  int get totalAbsent =>
      employeeReports.fold<int>(0, (s, r) => s + r.absentDays);

  Future<void> loadReport() async {
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final rows = await _dashboardService.fetchMonthlyReport(
        companyId,
        selectedMonth.value,
      );

      // Group by user_id
      final Map<String, _EmpAgg> agg = {};

      for (final row in rows) {
        final userId = row['user_id'] as String? ?? '';
        final profile = row['profiles'] as Map<String, dynamic>?;
        final status = row['status'] as String? ?? 'absent';

        agg.putIfAbsent(
          userId,
          () => _EmpAgg(
            name: profile?['name'] as String? ?? 'Unknown',
            employeeId: profile?['employee_id'] as String? ?? '',
          ),
        );

        final e = agg[userId]!;
        if (status == 'present') {
          e.presentDays++;
        } else if (status == 'late') {
          e.lateDays++;
        } else {
          e.absentDays++;
        }

        // Calculate working hours from check-in/out
        final checkIn = row['check_in_time'] != null
            ? DateTime.tryParse(row['check_in_time'] as String)
            : null;
        final checkOut = row['check_out_time'] != null
            ? DateTime.tryParse(row['check_out_time'] as String)
            : null;
        if (checkIn != null && checkOut != null) {
          var work = checkOut.difference(checkIn);
          // Subtract break
          final breakStart = row['break_start_time'] != null
              ? DateTime.tryParse(row['break_start_time'] as String)
              : null;
          final breakEnd = row['break_end_time'] != null
              ? DateTime.tryParse(row['break_end_time'] as String)
              : null;
          if (breakStart != null && breakEnd != null) {
            work -= breakEnd.difference(breakStart);
          }
          if (work.isNegative) work = Duration.zero;
          e.totalMinutes += work.inMinutes;
        }
      }

      final workDays = totalWorkDays;
      employeeReports.value = agg.values.map((e) {
        final attended = e.presentDays + e.lateDays;
        final rate = workDays > 0 ? (attended / workDays * 100) : 0.0;
        return EmployeeReport(
          name: e.name,
          employeeId: e.employeeId,
          presentDays: e.presentDays,
          lateDays: e.lateDays,
          absentDays: e.absentDays,
          totalWorkingHours: Duration(minutes: e.totalMinutes),
          attendanceRate: rate.clamp(0, 100),
        );
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('loadReport error: $e');
      errorMessage.value = 'Failed to load report: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(DateTime month) {
    selectedMonth.value = month;
    loadReport();
  }

  void prevMonth() {
    final m = selectedMonth.value;
    changeMonth(DateTime(m.year, m.month - 1));
  }

  void nextMonth() {
    final m = selectedMonth.value;
    final next = DateTime(m.year, m.month + 1);
    if (next.isAfter(DateTime.now())) return;
    changeMonth(next);
  }

  Future<void> refresh() => loadReport();

  // ── CSV Export ──────────────────────────────────────────────────────────

  void exportReportCsv() {
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
    final buffer = StringBuffer();
    buffer.writeln(
      'Employee Name,Employee ID,Present Days,Late Days,Absent Days,'
      'Working Hours,Attendance Rate (%)',
    );

    for (final r in employeeReports) {
      final hours = '${r.totalWorkingHours.inHours}h ${r.totalWorkingHours.inMinutes.remainder(60)}m';
      buffer.writeln(
        '${_csvSafe(r.name)},${_csvSafe(r.employeeId)},${r.presentDays},'
        '${r.lateDays},${r.absentDays},$hours,${r.attendanceRate.toStringAsFixed(1)}',
      );
    }

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: unused_local_variable
    html.AnchorElement(href: url)
      ..setAttribute('download', 'report_$monthStr.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  String _csvSafe(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

class _EmpAgg {
  final String name;
  final String employeeId;
  int presentDays = 0;
  int lateDays = 0;
  int absentDays = 0;
  int totalMinutes = 0;

  _EmpAgg({required this.name, required this.employeeId});
}

class EmployeeReport {
  final String name;
  final String employeeId;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final Duration totalWorkingHours;
  final double attendanceRate;

  const EmployeeReport({
    required this.name,
    required this.employeeId,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.totalWorkingHours,
    required this.attendanceRate,
  });
}
