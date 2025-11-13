import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF5D2E0F);
  static const Color lightBrown = Color(0xFFD2691E);
  static const Color cream = Color(0xFFFFF8DC);
  static const Color backgroundCream = Color(0xFFFAF0E6);
  static const Color parchment = Color(0xFFF4E8C1);
  static const Color accentGold = Color(0xFFDAA520);
  static const Color darkGold = Color(0xFFB8860B);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF5D2E0F),
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8B4513),
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Color(0xFF5D2E0F),
  );
  
  static const TextStyle vintage = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Color(0xFF8B4513),
  );
}

// Reading Status
enum ReadingStatus {
  notStarted,
  reading,
  finished,
}

extension ReadingStatusExtension on ReadingStatus {
  String get displayName {
    switch (this) {
      case ReadingStatus.notStarted:
        return "Haven't Read";
      case ReadingStatus.reading:
        return "Reading";
      case ReadingStatus.finished:
        return "Done Reading";
    }
  }
}
