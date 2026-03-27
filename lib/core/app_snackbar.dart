import 'package:get/get.dart';
import 'package:status_snackbar/status_snackbar.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Success'}) {
    final ctx = Get.context;
    if (ctx == null) return;
    StatusSnackbar.showSuccess(
      ctx,
      message,
      subTitle: title != 'Success' ? title : null,
      position: SnackbarPosition.top,
      durationSeconds: 3,
    );
  }

  static void error(String message, {String title = 'Error'}) {
    final ctx = Get.context;
    if (ctx == null) return;
    StatusSnackbar.showError(
      ctx,
      message,
      subTitle: title != 'Error' ? title : null,
      position: SnackbarPosition.top,
      durationSeconds: 4,
    );
  }

  static void warning(String message, {String title = 'Warning'}) {
    final ctx = Get.context;
    if (ctx == null) return;
    StatusSnackbar.showWarning(
      ctx,
      message,
      subTitle: title != 'Warning' ? title : null,
      position: SnackbarPosition.top,
      durationSeconds: 3,
    );
  }

  static void info(String message, {String title = 'Info'}) {
    final ctx = Get.context;
    if (ctx == null) return;
    StatusSnackbar.showInfo(
      ctx,
      message,
      subTitle: title != 'Info' ? title : null,
      position: SnackbarPosition.top,
      durationSeconds: 3,
    );
  }
}
