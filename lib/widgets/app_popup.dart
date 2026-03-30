import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/colors.dart';
import '../values/dimensions.dart';
import 'app_button.dart';
import 'app_loader.dart';

class AppPopup extends StatelessWidget {
  final String title;
  final String? message;
  final RichText? messageWidget;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final RxBool isProcessing;

  /// When true, confirm button uses danger style.
  final bool isDestructive;

  /// For progress popup (e.g. sync/download).
  final RxInt? savedCount;
  final RxInt? totalCount;
  final bool showProgress;

  /// Whether tapping outside dismisses the popup.
  final bool barrierDismissible;

  const AppPopup({
    super.key,
    required this.title,
    this.message,
    this.messageWidget,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    required this.isProcessing,
    this.isDestructive = false,
    this.savedCount,
    this.totalCount,
    this.showProgress = false,
    this.barrierDismissible = true,
  }) : assert(
         message != null || messageWidget != null,
         'Provide either message or messageWidget',
       );

  /// Convenience method to show the popup via GetX overlay.
  static void show({
    required String title,
    String? message,
    RichText? messageWidget,
    required String confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    RxBool? isProcessing,
    bool isDestructive = false,
    RxInt? savedCount,
    RxInt? totalCount,
    bool showProgress = false,
    bool barrierDismissible = true,
  }) {
    final processing = isProcessing ?? false.obs;

    Get.dialog(
      AppPopup(
        title: title,
        message: message,
        messageWidget: messageWidget,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        isProcessing: processing,
        isDestructive: isDestructive,
        savedCount: savedCount,
        totalCount: totalCount,
        showProgress: showProgress,
        barrierDismissible: barrierDismissible,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final shadowColor = isDark ? AppColors.shadowDark : AppColors.shadow;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: _popupWidth(context),
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppDimensions.paddingXXL),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: AppDimensions.shadowBlurM),
            ],
          ),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                if (showProgress && savedCount != null && totalCount != null)
                  _buildProgressContent(theme, isDark)
                else
                  _buildNormalContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _popupWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // On web/desktop use a fixed-ish width; on narrow screens fill more
    if (screenWidth > 600) return 400;
    return screenWidth * 0.85;
  }

  Widget _buildProgressContent(ThemeData theme, bool isDark) {
    final total = totalCount!.value == 0 ? 1 : totalCount!.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLoader(size: AppDimensions.avatarL),
        const SizedBox(height: AppDimensions.paddingL),
        Text(
          '${savedCount!.value}/$total Saved',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
          child: LinearProgressIndicator(
            value: savedCount!.value / total,
            color: AppColors.primary,
            backgroundColor:
                isDark ? AppColors.borderDarkMode : AppColors.border,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Text(
          'Downloading please wait...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        messageWidget ??
            Text(
              message ?? '',
              textAlign: TextAlign.center,
            ),
        const SizedBox(height: AppDimensions.paddingXXL),
        Row(
          children: [
            if (cancelText != null) ...[
              Expanded(
                child: AppButton(
                  label: cancelText!,
                  onPressed: () => Get.back(),
                  type: AppButtonType.outlined,
                  size: AppButtonSize.medium,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
            ],
            Expanded(
              child: AppButton(
                label: confirmText,
                onPressed: isProcessing.value ? null : onConfirm,
                isLoading: isProcessing.value,
                type: isDestructive
                    ? AppButtonType.danger
                    : AppButtonType.primary,
                size: AppButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
