import 'package:flutter/material.dart';
import '../values/colors.dart';
import '../values/dimensions.dart';
import 'app_loader.dart';

enum AppButtonType { primary, outlined, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double vertical;
    final double horizontal;
    final double fontSize;
    switch (size) {
      case AppButtonSize.small:
        vertical = 8;
        horizontal = 14;
        fontSize = 13;
      case AppButtonSize.medium:
        vertical = 12;
        horizontal = 20;
        fontSize = 14;
      case AppButtonSize.large:
        vertical = 16;
        horizontal = 28;
        fontSize = 16;
    }

    final buttonPadding = EdgeInsets.symmetric(
      vertical: vertical,
      horizontal: horizontal,
    );
    final borderRadius = BorderRadius.circular(AppDimensions.radiusS);

    if (type == AppButtonType.outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: buttonPadding,
          side: BorderSide(
            color: isDark ? AppColors.borderDarkMode : AppColors.border,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        child: _buildChild(fontSize, isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
      );
    }

    final bgColor = type == AppButtonType.danger ? AppColors.error : AppColors.primary;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
        padding: buttonPadding,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: _buildChild(fontSize, Colors.white),
    );
  }

  Widget _buildChild(double fontSize, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: const AppLoader(size: 18, color: Colors.white, strokeWidth: 2),
      );
    }

    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: 6),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}
