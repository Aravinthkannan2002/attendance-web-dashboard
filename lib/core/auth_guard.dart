import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/web_auth_service.dart';
import 'routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<WebAuthService>();
    if (!authService.isLoggedIn || authService.currentCompanyId.value.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
