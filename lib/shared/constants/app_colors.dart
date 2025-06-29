import 'package:flutter/material.dart';

/// AppColors provides a centralized place to manage all color constants used in the application.
/// Colors are organized by their semantic meaning and usage.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF305CDE);
  static const Color primaryLight = Color(0xFF5B7BE8);
  static const Color primaryDark = Color(0xFF1E3FA3);

  // Secondary Colors
  static const Color secondary = Color(0xFF20B2AA); // Teal
  static const Color secondaryLight = Color(0xFF48C9B0);
  static const Color secondaryDark = Color(0xFF1A8A7A);

  // Background Colors
  static const Color background = Color(0xFFFAFBFF);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF5F7FF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red (kept for errors)
  static const Color info = Color(0xFF3B82F6); // Blue

  // Queue Status Colors
  static const Color queueActive = Color(0xFF10B981); // Green
  static const Color queuePaused = Color(0xFFF59E0B); // Amber
  static const Color queueClosed = Color(0xFF6B7280); // Gray instead of red
  static const Color queueCompleted = Color(0xFF3B82F6); // Blue

  // Button Colors
  static const Color buttonPrimary = Color(0xFF305CDE);
  static const Color buttonSecondary = Color(0xFFF4F0F0);
  static const Color buttonDisabled = Color(0xFFB8B0B0);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE5E7EB);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Category Colors (Updated to blue/teal theme)
  static const Color categoryFood = Color(0xFF3B82F6); // Blue
  static const Color categoryFitness = Color(0xFF10B981); // Green
  static const Color categoryBeauty = Color(0xFF8B5CF6); // Purple
  static const Color categoryMedical = Color(0xFF06B6D4); // Cyan
  static const Color categoryGrocery = Color(0xFFF59E0B); // Amber
  static const Color categoryElectronics = Color(0xFF6366F1); // Indigo
  static const Color categoryClothing = Color(0xFF20B2AA); // Teal
  static const Color categoryHome = Color(0xFF64748B); // Slate

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF305CDE),
    Color(0xFF5B7BE8),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF20B2AA),
    Color(0xFF48C9B0),
  ];

  // Material Color Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF305CDE,
    <int, Color>{
      50: Color(0xFFF3F2F2),
      100: Color(0xFFE7E5E5),
      200: Color(0xFFCFCBCB),
      300: Color(0xFFB7B1B1),
      400: Color(0xFF9F9797),
      500: Color(0xFF305CDE), // Primary color
      600: Color(0xFF130E0E),
      700: Color(0xFF0E0B0B),
      800: Color(0xFF0A0808),
      900: Color(0xFF050404),
    },
  );
}
