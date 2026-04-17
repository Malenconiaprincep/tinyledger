import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 布局与圆角（Stitch「趣味探索版」主帧：`get_screen` 项目 16236738106685052013）。
abstract final class TinyLedgerLayout {
  static const double cardRadius = 20;
  static const double sheetRadius = 24;
  static const double pillButtonRadius = 999;
}

/// 浅色 ColorScheme：来自 **首页/资产 - 趣味探索版** `htmlCode` tailwind tokens（2026-04 MCP）。
/// 主参考：`projects/16236738106685052013/screens/be63fb89830a4850b779356efecb3613`
ColorScheme _playfulExplorerScheme() {
  const primary = Color(0xFF296654);
  const onPrimary = Color(0xFFC5FFE9);
  const primaryContainer = Color(0xFFACEAD3);
  const onPrimaryContainer = Color(0xFF195847);
  const secondary = Color(0xFF6F5174);
  const onSecondary = Color(0xFFFFEEFD);
  const secondaryContainer = Color(0xFFFAD3FD);
  const onSecondaryContainer = Color(0xFF634668);
  const tertiary = Color(0xFF785246);
  const onTertiary = Color(0xFFFFEFEB);
  const tertiaryContainer = Color(0xFFFFCCBC);
  const onTertiaryContainer = Color(0xFF664237);
  const surface = Color(0xFFF5F6F7);
  const onSurface = Color(0xFF2C2F30);
  const surfaceContainerLow = Color(0xFFEFF1F2);
  const surfaceContainerHigh = Color(0xFFE0E3E4);
  const surfaceContainerLowest = Color(0xFFFFFFFF);
  const outlineVariant = Color(0xFFABADAE);
  const error = Color(0xFFB31B25);
  const onError = Color(0xFFFFEFEE);

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
    surfaceTint: primary,
    // 供渐变等使用（非 ColorScheme 标准槽位，首页局部 const 引用 primaryDim/secondaryDim）
  );
}

/// 探索版渐变用色（与稿 tailwind `primary-dim` / `secondary-dim` 一致）。
abstract final class TinyLedgerPlayfulColors {
  static const primaryDim = Color(0xFF1B5948);
  static const secondaryDim = Color(0xFF624568);
}

ThemeData buildTinyLedgerTheme() {
  final scheme = _playfulExplorerScheme();
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
      backgroundColor: scheme.surfaceContainerLowest.withValues(alpha: 0.92),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      indicatorColor: scheme.primary,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          // 选中态文字在指示器外，需使用深色避免“白字白底”不可见。
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : scheme.onSurfaceVariant,
          size: 24,
        );
      }),
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
