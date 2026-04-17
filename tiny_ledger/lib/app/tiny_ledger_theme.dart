import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 布局与圆角常量（与 Stitch 温馨版主帧大圆角卡片一致；项目 16236738106685052013）。
abstract final class TinyLedgerLayout {
  static const double cardRadius = 20;
  static const double sheetRadius = 24;
  static const double pillButtonRadius = 999;
}

/// 浅色 ColorScheme：以「iOS 温馨版」主帧 `get_screen` 气质为准（偏暖底 + 清晰主色），
/// 与 `get_project.designTheme` 冲突时以单帧为准。
ColorScheme _stitchLightScheme() {
  const primary = Color(0xFF2F4FD6);
  const onPrimary = Color(0xFFFFFFFF);
  const primaryContainer = Color(0xFF5C6BC0);
  const onPrimaryContainer = Color(0xFFE8EAFF);
  const secondary = Color(0xFF3D6B52);
  const onSecondary = Color(0xFFFFFFFF);
  const secondaryContainer = Color(0xFFC8EFD6);
  const onSecondaryContainer = Color(0xFF1E4A30);
  const tertiary = Color(0xFF8C4A3C);
  const onTertiary = Color(0xFFFFFFFF);
  const tertiaryContainer = Color(0xFFFFDAD4);
  const onTertiaryContainer = Color(0xFF5C1F16);
  const surface = Color(0xFFFFF9F5);
  const onSurface = Color(0xFF1C1B1F);
  const surfaceContainerLow = Color(0xFFF5F0EB);
  const surfaceContainerHigh = Color(0xFFE8E3DD);
  const surfaceContainerLowest = Color(0xFFFFFCFA);
  const outlineVariant = Color(0xFFC5C5D4);
  const error = Color(0xFFBA1A1A);
  const onError = Color(0xFFFFFFFF);

  final base = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  );
  return base.copyWith(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerLowest: surfaceContainerLowest,
    outlineVariant: outlineVariant,
    error: error,
    onError: onError,
  );
}

ThemeData buildTinyLedgerTheme() {
  final scheme = _stitchLightScheme();
  final baseText = ThemeData(useMaterial3: true, colorScheme: scheme).textTheme;
  final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseText);

  final filledShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(TinyLedgerLayout.pillButtonRadius),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer.withValues(alpha: 0.35),
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TinyLedgerLayout.cardRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: filledShape,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: filledShape,
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
    ),
  );
}
