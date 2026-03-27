import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/dashboard_service.dart';
import '../services/web_auth_service.dart';

class OverviewController extends GetxController {
  late DashboardService _dashboardService;
  late WebAuthService _authService;

  // ── Stats ──────────────────────────────────────────────────────────────────
  final RxInt totalEmployees = 0.obs;
  final RxInt registeredFaces = 0.obs;
  final RxInt presentToday = 0.obs;
  final RxInt lateToday = 0.obs;
  final RxInt absentToday = 0.obs;

  // ── Chart data ─────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> weeklyData =
      <Map<String, dynamic>>[].obs;
  final RxInt chartDays = 7.obs;

  // ── Today's activity feed ──────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> todayActivity =
      <Map<String, dynamic>>[].obs;

  // ── Loading ────────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ── Realtime ───────────────────────────────────────────────────────────────
  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    _dashboardService = Get.find<DashboardService>();
    _authService = Get.find<WebAuthService>();
    loadAll();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;

    try {
      _realtimeChannel = _dashboardService.subscribeToAttendance(
        companyId,
        () {
          debugPrint('Realtime: attendance update received, refreshing...');
          loadAll();
        },
      );
    } catch (e) {
      debugPrint('Realtime subscription error: $e');
    }
  }

  Future<void> loadAll() async {
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _dashboardService.fetchOverviewStats(companyId),
        _dashboardService.fetchWeeklyAttendance(companyId, days: chartDays.value),
        _dashboardService.fetchTodayActivity(companyId),
      ]);

      final stats = results[0] as Map<String, int>;
      totalEmployees.value = stats['totalEmployees'] ?? 0;
      registeredFaces.value = stats['registeredFaces'] ?? 0;
      presentToday.value = stats['presentToday'] ?? 0;
      lateToday.value = stats['lateToday'] ?? 0;
      absentToday.value = stats['absentToday'] ?? 0;

      weeklyData.value =
          results[1] as List<Map<String, dynamic>>;

      todayActivity.value =
          results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      errorMessage.value = 'Failed to load data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void setChartRange(int days) {
    chartDays.value = days;
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;
    _dashboardService
        .fetchWeeklyAttendance(companyId, days: days)
        .then((data) => weeklyData.value = data);
  }

  Future<void> refresh() => loadAll();

  double get attendanceRate {
    if (totalEmployees.value == 0) return 0;
    return ((presentToday.value + lateToday.value) /
            totalEmployees.value *
            100)
        .clamp(0, 100);
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }
}
