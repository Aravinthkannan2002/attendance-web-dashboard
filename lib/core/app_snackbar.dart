import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Success'}) {
    _show(
      type: ToastificationType.success,
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  static void error(String message, {String title = 'Error'}) {
    _show(
      type: ToastificationType.error,
      title: title,
      message: message,
      duration: const Duration(seconds: 4),
    );
  }

  static void warning(String message, {String title = 'Warning'}) {
    _show(
      type: ToastificationType.warning,
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  static void info(String message, {String title = 'Info'}) {
    _show(
      type: ToastificationType.info,
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  static void _show({
    required ToastificationType type,
    required String title,
    required String message,
    required Duration duration,
  }) {
    final ctx = Get.context;
    if (ctx == null) return;

    toastification.show(
      context: ctx,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: duration,
      animationDuration: const Duration(milliseconds: 300),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }
}
