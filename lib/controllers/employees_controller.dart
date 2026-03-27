import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/app_snackbar.dart';
import '../models/employee_model.dart';
import '../services/dashboard_service.dart';
import '../services/web_auth_service.dart';

class EmployeesController extends GetxController {
  late DashboardService _dashboardService;
  late WebAuthService _authService;

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _dashboardService = Get.find<DashboardService>();
    _authService = Get.find<WebAuthService>();
    fetchEmployees();
  }

  List<EmployeeModel> get filteredEmployees {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return employees;
    return employees.where((e) {
      return e.name.toLowerCase().contains(query) ||
          e.employeeId.toLowerCase().contains(query) ||
          (e.department?.toLowerCase().contains(query) ?? false) ||
          (e.designation?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<EmployeeModel> get paginatedEmployees {
    final all = filteredEmployees;
    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  int get totalPages =>
      (filteredEmployees.length / pageSize).ceil().clamp(1, 9999);

  bool get hasPrevPage => currentPage.value > 0;
  bool get hasNextPage => currentPage.value < totalPages - 1;

  void nextPage() {
    if (hasNextPage) currentPage.value++;
  }

  void prevPage() {
    if (hasPrevPage) currentPage.value--;
  }

  void onSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
  }

  Future<void> fetchEmployees() async {
    final companyId = _authService.getCompanyId();
    if (companyId.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _dashboardService.fetchEmployees(companyId);
      employees.value = data;
      currentPage.value = 0;
    } catch (e) {
      errorMessage.value = 'Failed to load employees: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Edit employee ─────────────────────────────────────────────────────────

  Future<void> updateEmployee(
    EmployeeModel employee, {
    required String name,
    required String employeeId,
    String? department,
    String? designation,
  }) async {
    try {
      await _dashboardService.updateEmployee(employee.id, {
        'name': name,
        'employee_id': employeeId,
        'department': department,
        'designation': designation,
      });
      AppSnackbar.success('${employee.name} updated successfully.');
      await fetchEmployees();
    } catch (e) {
      debugPrint('updateEmployee error: $e');
      AppSnackbar.error('Failed to update employee: $e');
    }
  }

  // ── Add new employee ───────────────────────────────────────────────────────

  Future<bool> addEmployee({
    required String name,
    String? employeeId,
    String? department,
    String? designation,
  }) async {
    try {
      final companyId = _authService.getCompanyId();
      await _dashboardService.createEmployee(
        companyId,
        name: name,
        employeeId: employeeId,
        department: department,
        designation: designation,
      );
      AppSnackbar.success('$name added successfully.');
      await fetchEmployees();
      return true;
    } catch (e) {
      debugPrint('addEmployee error: $e');
      AppSnackbar.error('Failed to add employee: $e');
      return false;
    }
  }

  // ── Toggle active/inactive ────────────────────────────────────────────────

  Future<void> toggleActive(EmployeeModel employee) async {
    try {
      final newState = !employee.isActive;
      await _dashboardService.toggleEmployeeActive(employee.id, newState);
      AppSnackbar.success(
        '${employee.name} ${newState ? 'activated' : 'deactivated'}.',
      );
      await fetchEmployees();
    } catch (e) {
      debugPrint('toggleActive error: $e');
      AppSnackbar.error('Failed to update status: $e');
    }
  }

  Future<void> refresh() => fetchEmployees();
}
