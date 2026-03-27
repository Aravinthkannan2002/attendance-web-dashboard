import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
      textColor: const Color(0xFF2E7D32),
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF4CAF50),
    );
  }

  static void error(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.red.withValues(alpha: 0.12),
      textColor: Colors.red.shade800,
      icon: Icons.error_rounded,
      iconColor: Colors.red,
    );
  }

  static void warning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFFF9800).withValues(alpha: 0.12),
      textColor: const Color(0xFFE65100),
      icon: Icons.warning_rounded,
      iconColor: const Color(0xFFFF9800),
    );
  }

  static void info(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
      textColor: const Color(0xFF0D47A1),
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF1E88E5),
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: iconColor, size: 20),
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      maxWidth: 480,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
