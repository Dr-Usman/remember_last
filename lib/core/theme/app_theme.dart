import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.onAccent,
      secondary: AppColors.dueSoon,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.dueSoonContainerLight,
      onSecondaryContainer: AppColors.textDark,
      tertiary: AppColors.recent,
      onTertiary: AppColors.onAccent,
      error: AppColors.overdue,
      onError: AppColors.onAccent,
      surface: AppColors.bgLight,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.neutral,
      outline: AppColors.neutral,
      outlineVariant: AppColors.outlineVariantLight,
      // Scaffold → card → chip hierarchy (must differ so chips read on cards)
      surfaceContainerLowest: AppColors.cardLight,
      surfaceContainerLow: AppColors.cardLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
    );
    return _build(
      scheme,
      scaffoldBg: AppColors.bgLight,
      cardColor: AppColors.cardLight,
    );
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
      secondaryContainer: AppColors.dueSoonContainerDark,
      onSecondaryContainer: AppColors.textLight,
      tertiary: AppColors.recent,
      onTertiary: AppColors.bgDark,
      error: AppColors.overdue,
      onError: AppColors.onAccent,
      surface: AppColors.bgDark,
      onSurface: AppColors.textLight,
      onSurfaceVariant: AppColors.neutral,
      outline: AppColors.neutral,
      outlineVariant: AppColors.outlineVariantDark,
      // Scaffold → card → chip hierarchy (must differ so chips read on cards)
      surfaceContainerLowest: AppColors.cardDark,
      surfaceContainerLow: AppColors.cardDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
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
        // Light: card surface so fields don't look disabled on the grey scaffold.
        // Dark: highest container for contrast on dark surfaces.
        fillColor: scheme.brightness == Brightness.light
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainerHighest,
      ),
      // Filter chips: brand primary when selected (not secondary/due-soon orange).
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        showCheckmark: true,
        checkmarkColor: scheme.primary,
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final alpha = scheme.brightness == Brightness.light ? 0.14 : 0.28;
            return Color.alphaBlend(
              scheme.primary.withValues(alpha: alpha),
              scheme.surface,
            );
          }
          return scheme.surfaceContainerHigh;
        }),
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
