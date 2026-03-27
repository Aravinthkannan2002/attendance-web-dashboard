import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';
import 'core/supabase_config.dart';
import 'services/web_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Register theme controller globally
  Get.put(DashboardThemeController(), permanent: true);

  // Register the auth service globally so it persists across routes
  final authService = await Get.putAsync<WebAuthService>(
    () => WebAuthService().init(),
    permanent: true,
  );

  // Determine initial route
  String initialRoute = AppRoutes.login;
  if (authService.isLoggedIn && authService.currentCompanyId.value.isNotEmpty) {
    initialRoute = AppRoutes.dashboard;
  }

  runApp(AttendanceDashboardApp(initialRoute: initialRoute));
}

class AttendanceDashboardApp extends StatelessWidget {
  final String initialRoute;

  const AttendanceDashboardApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<DashboardThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Attendance Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: initialRoute,
          getPages: appPages,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 200),
          unknownRoute: GetPage(
            name: '/404',
            page: () => const _NotFoundPage(),
          ),
        ));
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
