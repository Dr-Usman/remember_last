import 'package:flutter/material.dart';

/// Status and accent colors used throughout RememberLast.
abstract final class AppColors {
  static const recent = Color(0xFF4CAF50);
  static const dueSoon = Color(0xFFFF9800);
  static const overdue = Color(0xFFEF5350);
  static const neutral = Color(0xFF78909C);

  static const seed = Color(0xFF00897B);

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
