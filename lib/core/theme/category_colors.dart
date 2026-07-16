import 'package:flutter/material.dart';

/// Curated palette for category chips — stable, brand-friendly hues.
abstract final class CategoryColors {
  static const List<Color> palette = [
    Color(0xFF3A86FF), // primary blue
    Color(0xFF2ECC71), // green
    Color(0xFFFF9F43), // amber
    Color(0xFF9B59B6), // purple
    Color(0xFF1ABC9C), // teal
    Color(0xFFE74C3C), // red
    Color(0xFF3498DB), // sky
    Color(0xFFF39C12), // orange
    Color(0xFF16A085), // sea green
    Color(0xFF8E44AD), // deep purple
  ];

  /// Stable palette color from [name] (same name → same color).
  static Color pickForName(String name) {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return palette.first;
    final hash = key.codeUnits.fold<int>(0, (h, c) => 31 * h + c);
    return palette[hash.abs() % palette.length];
  }

  static int argbForName(String name) => pickForName(name).toARGB32();

  static Color fromArgb(int argb) => Color(argb);
}
