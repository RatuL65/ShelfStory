import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color cream = Color(0xFFFFF8DC);
  static const Color backgroundCream = Color(0xFFFFFAF0);
  static const Color accentGold = Color(0xFFDAA520);
  static const Color parchment = Color(0xFFF5E6D3);
  static const Color vintage = Color(0xFFD4A574);
  static const Color darkGold = Color(0xFFB8860B);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkPrimary = Color(0xFFDAA520);
  static const Color darkText = Color(0xFFE5E5E5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}

class AppTextStyles {
  // Theme-aware text styles (methods)
  static TextStyle heading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.darkText : AppColors.darkBrown,
    );
  }

  static TextStyle subheading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkText : AppColors.primaryBrown,
    );
  }

  static TextStyle body(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
    );
  }

  static TextStyle vintage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      color: isDark ? AppColors.darkTextSecondary : AppColors.vintage,
      fontStyle: FontStyle.italic,
    );
  }
}
