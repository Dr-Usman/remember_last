import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.dueSoon,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE8D1),
      onSecondaryContainer: AppColors.textDark,
      tertiary: AppColors.recent,
      onTertiary: Colors.white,
      error: AppColors.overdue,
      onError: Colors.white,
      surface: AppColors.bgLight,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.neutral,
      outline: AppColors.neutral,
      outlineVariant: Color(0xFFD1D5DB),
      // Scaffold → card → chip hierarchy (must differ so chips read on cards)
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Color(0xFFF0F3F7),
      surfaceContainerHigh: Color(0xFFE8ECF2),
      surfaceContainerHighest: Color(0xFFE2E8F0),
    );
    return _build(scheme, scaffoldBg: AppColors.bgLight, cardColor: Colors.white);
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDarkMode,
      onPrimary: AppColors.bgDark,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textLight,
      secondary: AppColors.dueSoon,
      onSecondary: AppColors.bgDark,
      secondaryContainer: Color(0xFF3D2A14),
      onSecondaryContainer: AppColors.textLight,
      tertiary: AppColors.recent,
      onTertiary: AppColors.bgDark,
      error: AppColors.overdue,
      onError: Colors.white,
      surface: AppColors.bgDark,
      onSurface: AppColors.textLight,
      onSurfaceVariant: AppColors.neutral,
      outline: AppColors.neutral,
      outlineVariant: Color(0xFF374151),
      // Scaffold → card → chip hierarchy (must differ so chips read on cards)
      surfaceContainerLowest: AppColors.cardDark,
      surfaceContainerLow: AppColors.cardDark,
      surfaceContainer: Color(0xFF151C2C),
      surfaceContainerHigh: Color(0xFF1A2332),
      surfaceContainerHighest: Color(0xFF1F2937),
    );
    return _build(
      scheme,
      scaffoldBg: AppColors.bgDark,
      cardColor: AppColors.cardDark,
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required Color scaffoldBg,
    required Color cardColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}
