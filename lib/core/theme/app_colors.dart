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

  // Neutrals — light
  static const textDark = Color(0xFF1F2937);
  static const bgLight = Color(0xFFF5F7FA);

  // Neutrals — dark
  static const bgDark = Color(0xFF0F172A);
  static const cardDark = Color(0xFF111827);
  static const textLight = Color(0xFFE5E7EB);

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
