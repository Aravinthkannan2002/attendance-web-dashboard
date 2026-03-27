import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/overview_controller.dart';
import '../controllers/employees_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/reports_controller.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_layout.dart';
import '../screens/overview_screen.dart';
import '../screens/employees_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/reports_screen.dart';
import '../services/web_auth_service.dart';
import '../services/dashboard_service.dart';
import 'auth_guard.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const employees = '/dashboard/employees';
  static const attendance = '/dashboard/attendance';
  static const reports = '/dashboard/reports';
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebAuthService>(() => WebAuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebAuthService>(() => WebAuthService(), fenix: true);
    Get.lazyPut<DashboardService>(() => DashboardService(), fenix: true);
    Get.lazyPut<OverviewController>(() => OverviewController(), fenix: true);
  }
}

class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebAuthService>(() => WebAuthService(), fenix: true);
    Get.lazyPut<DashboardService>(() => DashboardService(), fenix: true);
    Get.lazyPut<EmployeesController>(() => EmployeesController(), fenix: true);
  }
}

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebAuthService>(() => WebAuthService(), fenix: true);
    Get.lazyPut<DashboardService>(() => DashboardService(), fenix: true);
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(),
      fenix: true,
    );
  }
}

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebAuthService>(() => WebAuthService(), fenix: true);
    Get.lazyPut<DashboardService>(() => DashboardService(), fenix: true);
    Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
  }
}

final List<GetPage> appPages = [
  GetPage(
    name: AppRoutes.login,
    page: () => const LoginScreen(),
    binding: AuthBinding(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: AppRoutes.dashboard,
    page: () => DashboardLayout(child: const OverviewScreen()),
    binding: DashboardBinding(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard()],
  ),
  GetPage(
    name: AppRoutes.employees,
    page: () => DashboardLayout(child: const EmployeesScreen()),
    binding: EmployeesBinding(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard()],
  ),
  GetPage(
    name: AppRoutes.attendance,
    page: () => DashboardLayout(child: const AttendanceScreen()),
    binding: AttendanceBinding(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard()],
  ),
  GetPage(
    name: AppRoutes.reports,
    page: () => DashboardLayout(child: const ReportsScreen()),
    binding: ReportsBinding(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard()],
  ),
];
