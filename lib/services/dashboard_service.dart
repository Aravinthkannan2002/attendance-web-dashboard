import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';
import '../models/employee_model.dart';

class DashboardService extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Overview stats ─────────────────────────────────────────────────────────

  Future<Map<String, int>> fetchOverviewStats(String companyId) async {
    final today = _todayString();

    final results = await Future.wait([
      // Total employees (non-admin)
      _client
          .from('profiles')
          .select('id')
          .eq('company_id', companyId)
          .eq('role', 'employee')
          .eq('is_active', true),

      // Face registered
      _client
          .from('profiles')
          .select('id')
          .eq('company_id', companyId)
          .eq('role', 'employee')
          .eq('is_active', true)
          .eq('is_face_registered', true),

      // Present today
      _client
          .from('attendance')
          .select('id')
          .eq('company_id', companyId)
          .eq('date', today)
          .eq('status', 'present'),

      // Late today
      _client
          .from('attendance')
          .select('id')
          .eq('company_id', companyId)
          .eq('date', today)
          .eq('status', 'late'),

      // Absent today
      _client
          .from('attendance')
          .select('id')
          .eq('company_id', companyId)
          .eq('date', today)
          .eq('status', 'absent'),
    ]);

    return {
      'totalEmployees': (results[0] as List).length,
      'registeredFaces': (results[1] as List).length,
      'presentToday': (results[2] as List).length,
      'lateToday': (results[3] as List).length,
      'absentToday': (results[4] as List).length,
    };
  }

  // ── Weekly attendance ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchWeeklyAttendance(
    String companyId, {
    int days = 7,
  }) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateStr = _dateString(day);

      final rows = await _client
          .from('attendance')
          .select('status')
          .eq('company_id', companyId)
          .eq('date', dateStr);

      int present = 0;
      int late = 0;
      for (final row in rows as List) {
        if (row['status'] == 'present') present++;
        if (row['status'] == 'late') late++;
      }

      result.add({
        'date': day,
        'dateStr': dateStr,
        'presentCount': present,
        'lateCount': late,
      });
    }

    return result;
  }

  // ── Today's activity ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchTodayActivity(
    String companyId,
  ) async {
    final today = _todayString();

    final rows = await _client
        .from('attendance')
        .select('id, user_id, check_in_time, status, profiles(name, employee_id)')
        .eq('company_id', companyId)
        .eq('date', today)
        .not('check_in_time', 'is', null)
        .order('check_in_time', ascending: false)
        .limit(10);

    return (rows as List).map<Map<String, dynamic>>((row) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      return {
        'id': row['id'],
        'name': profile?['name'] ?? 'Unknown',
        'employeeId': profile?['employee_id'] ?? '',
        'checkInTime': row['check_in_time'] != null
            ? DateTime.parse(row['check_in_time'] as String).toLocal()
            : null,
        'status': row['status'] ?? 'unknown',
      };
    }).toList();
  }

  // ── Employees ──────────────────────────────────────────────────────────────

  Future<List<EmployeeModel>> fetchEmployees(String companyId) async {
    final rows = await _client
        .from('profiles')
        .select()
        .eq('company_id', companyId)
        .eq('role', 'employee')
        .order('name', ascending: true);

    return (rows as List)
        .map((r) => EmployeeModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new employee via Supabase RPC (bypasses auth.users FK).
  /// Requires the `create_employee` DB function — see migration SQL.
  Future<void> createEmployee(
    String companyId, {
    required String name,
    String? employeeId,
    String? department,
    String? designation,
  }) async {
    await _client.rpc('create_employee', params: {
      'p_company_id': companyId,
      'p_name': name,
      'p_employee_id': employeeId ?? '',
      'p_department': department,
      'p_designation': designation,
    });
  }

  // ── Attendance records ─────────────────────────────────────────────────────

  Future<List<AttendanceModel>> fetchAttendanceRecords(
    String companyId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final fromStr =
        _dateString(from ?? DateTime.now().subtract(const Duration(days: 30)));
    final toStr = _dateString(to ?? DateTime.now());

    final rows = await _client
        .from('attendance')
        .select(
          'id, user_id, company_id, date, check_in_time, check_out_time, '
          'break_start_time, break_end_time, status, check_in_image_url, '
          'check_out_image_url, profiles(name, employee_id)',
        )
        .eq('company_id', companyId)
        .gte('date', fromStr)
        .lte('date', toStr)
        .order('date', ascending: false)
        .order('check_in_time', ascending: false);

    return (rows as List)
        .map((r) => AttendanceModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Employee management ───────────────────────────────────────────────────

  Future<void> updateEmployee(String employeeId, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', employeeId);
  }

  Future<void> toggleEmployeeActive(String employeeId, bool isActive) async {
    await _client.from('profiles').update({'is_active': isActive}).eq('id', employeeId);
  }

  // ── Monthly reports ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchMonthlyReport(
    String companyId,
    DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final startStr = _dateString(start);
    final endStr = _dateString(end);

    final rows = await _client
        .from('attendance')
        .select(
          'user_id, status, check_in_time, check_out_time, '
          'break_start_time, break_end_time, profiles(name, employee_id)',
        )
        .eq('company_id', companyId)
        .gte('date', startStr)
        .lte('date', endStr);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  // ── Realtime ────────────────────────────────────────────────────────────

  RealtimeChannel subscribeToAttendance(
    String companyId,
    void Function() onUpdate,
  ) {
    return _client
        .channel('attendance-$companyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _todayString() => _dateString(DateTime.now());

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
