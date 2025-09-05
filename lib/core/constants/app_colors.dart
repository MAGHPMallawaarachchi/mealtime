import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFFF58700);
  static const Color primaryLight = Color(0xFFFF9F40);
  static const Color primaryDark = Color(0xFFBF6500);

  // Leftover colors
  static const Color leftover = Color(0xFFFF8C00);
  static const Color leftoverLight = Color(0xFFFFA500);
  static const Color leftoverDark = Color(0xFFFF6B00);

  // Basic colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // Text colors
  static const Color textPrimary = Color(0xFF2D2B2E);
  static const Color textSecondary = Color(0xFF727272);
  static const Color textDark = Color(0xFF2D2D2D);

  // Background colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // With opacity helpers
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => black.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => white.withOpacity(opacity);
}
