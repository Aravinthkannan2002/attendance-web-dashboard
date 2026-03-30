import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Theme Controller ────────────────────────────────────────────────────────

class DashboardThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() => isDarkMode.value = !isDarkMode.value;
}

// ── App Theme ───────────────────────────────────────────────────────────────

class AppTheme {
  // ── Animation duration constants ──────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ── Spacing constants ─────────────────────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;
  static const double spacingXxxl = 32;

  // ── Shared brand colors ─────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF42A5F5);

  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFB8C00);
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF039BE5);

  // ── Light colors ────────────────────────────────────────────────────────
  static const Color backgroundGrey = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color sidebarBackground = Color(0xFF0D47A1);
  static const Color sidebarText = Colors.white;
  static const Color sidebarActiveItem = Color(0xFF1565C0);

  // ── Dark colors ─────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1B2E);
  static const Color darkCardBackground = Color(0xFF242540);
  static const Color darkSidebarBackground = Color(0xFF151627);
  static const Color darkTextPrimary = Color(0xFFE8E8ED);
  static const Color darkTextSecondary = Color(0xFF8B8CA7);
  static const Color darkBorderColor = Color(0xFF2E2F4A);
  static const Color darkInputFill = Color(0xFF2A2B45);

  // ── Shared shape constants ────────────────────────────────────────────
  static final BorderRadius _buttonRadius = BorderRadius.circular(10);
  static final BorderRadius _cardRadius = BorderRadius.circular(16);
  static final BorderRadius _inputRadius = BorderRadius.circular(10);
  static final BorderRadius _dialogRadius = BorderRadius.circular(20);

  // ── Context-aware helpers ───────────────────────────────────────────────
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color cardColorOf(BuildContext context) =>
      _isDark(context) ? darkCardBackground : cardBackground;

  static Color surfaceColorOf(BuildContext context) =>
      _isDark(context) ? darkBackground : backgroundGrey;

  static Color sidebarColorOf(BuildContext context) =>
      _isDark(context) ? darkSidebarBackground : sidebarBackground;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : textSecondary;

  static Color borderColorOf(BuildContext context) =>
      _isDark(context) ? darkBorderColor : borderColor;

  // ── Shared button text style ──────────────────────────────────────────
  static const TextStyle _buttonTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardBackground,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: primaryColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: _cardRadius,
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle: _buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle: _buttonTextStyle,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(
          color: textSecondary.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 15, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimary.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: durationNormal,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: primaryColor.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: _dialogRadius),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return textSecondary.withValues(alpha: 0.5);
          }
          return textSecondary.withValues(alpha: 0.25);
        }),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return 8.0;
          return 6.0;
        }),
        radius: const Radius.circular(100),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryLight,
        secondary: accentColor,
        surface: darkCardBackground,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: _cardRadius,
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle: _buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle: _buttonTextStyle,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputFill,
        border: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _inputRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        hintStyle: TextStyle(
          color: darkTextSecondary.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.3),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 15, color: darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary),
        bodySmall: TextStyle(fontSize: 12, color: darkTextSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkTextPrimary.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: darkBackground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: durationNormal,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: _dialogRadius),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderColor,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return darkTextSecondary.withValues(alpha: 0.5);
          }
          return darkTextSecondary.withValues(alpha: 0.25);
        }),
        thickness: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return 8.0;
          return 6.0;
        }),
        radius: const Radius.circular(100),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
