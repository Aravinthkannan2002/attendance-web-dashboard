import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_snackbar.dart';
import '../core/routes.dart';
import '../services/web_auth_service.dart';

class AuthController extends GetxController {
  late WebAuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<WebAuthService>();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final success = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
      // Error already shown by WebAuthService
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  void _showError(String message) {
    AppSnackbar.error(message, title: 'Login Failed');
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
