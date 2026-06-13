import 'package:flutter/material.dart';

class QTColors {
  // Base Colors
  static const Color bgPrimary = Color(0xFFF8FAFC);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFF1F5F9);

  // Brand Colors
  static const Color brandPrimary = Color(0xFFE11D48); // Rose Pink
  static const Color brandDark = Color(0xFFBE123C);
  static const Color brandLight = Color(0xFFFFF1F2);

  // Complexity Accents
  static const Color accentBeginner = Color(0xFF059669); // Emerald Green
  static const Color accentIntermediate = Color(0xFFF59E0B); // Amber
  static const Color accentExpert = Color(0xFF2563EB); // Blue

  // Dark Premium Accent (Obsidian)
  static const Color darkBase = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF151B28);
  static const Color darkElevated = Color(0xFF1E2433);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textContrast = Color(0xFFFFFFFF);

  // Slate palette
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);

  // Status Colors
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Complexity color helper
  static Color complexityColor(String complexity) {
    switch (complexity.toUpperCase()) {
      case 'BEGINNER':
        return accentBeginner;
      case 'INTERMEDIATE':
        return accentIntermediate;
      case 'EXPERT':
        return accentExpert;
      default:
        return accentBeginner;
    }
  }

  // Project status color helper
  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return accentBeginner;
      case 'ONGOING':
        return info;
      case 'DONE':
        return accentIntermediate;
      case 'CLOSED':
        return slate500;
      case 'OVERDUE':
        return error;
      default:
        return slate500;
    }
  }
}
