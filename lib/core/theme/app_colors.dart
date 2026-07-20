import 'package:flutter/material.dart';

/// Brand and status colors used throughout the app.
abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF3A86FF);
  static const primaryDark = Color(0xFF1F4FBF);
  static const primaryDarkMode = Color(0xFF4F9DFF);

  // Accents / status
  static const recent = Color(0xFF2ECC71);
  static const dueSoon = Color(0xFFFF9F43);
  static const overdue = Color(0xFFFF5A5F);
  static const neutral = Color(0xFF9CA3AF);

  /// Text / icons on solid brand or status fills.
  static const onAccent = Color(0xFFFFFFFF);

  // Neutrals — light
  static const textDark = Color(0xFF1F2937);
  static const bgLight = Color(0xFFF5F7FA);
  static const cardLight = Color(0xFFFFFFFF);
  static const outlineVariantLight = Color(0xFFD1D5DB);
  static const surfaceContainerLight = Color(0xFFF0F3F7);
  static const surfaceContainerHighLight = Color(0xFFE8ECF2);
  static const surfaceContainerHighestLight = Color(0xFFE2E8F0);
  static const dueSoonContainerLight = Color(0xFFFFE8D1);

  // Neutrals — dark
  static const bgDark = Color(0xFF0F172A);
  static const cardDark = Color(0xFF111827);
  static const textLight = Color(0xFFE5E7EB);
  static const outlineVariantDark = Color(0xFF374151);
  static const surfaceContainerDark = Color(0xFF151C2C);
  static const surfaceContainerHighDark = Color(0xFF1A2332);
  static const surfaceContainerHighestDark = Color(0xFF1F2937);
  static const dueSoonContainerDark = Color(0xFF3D2A14);

  static Color statusColor(ActivityStatusColor status) {
    switch (status) {
      case ActivityStatusColor.recent:
        return recent;
      case ActivityStatusColor.dueSoon:
        return dueSoon;
      case ActivityStatusColor.overdue:
        return overdue;
      case ActivityStatusColor.neutral:
        return neutral;
    }
  }
}

enum ActivityStatusColor { recent, dueSoon, overdue, neutral }
