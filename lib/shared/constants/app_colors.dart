import 'package:flutter/material.dart';

/// AppColors provides a centralized place to manage all color constants used in the application.
/// Colors are organized by their semantic meaning and usage.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF181111);
  static const Color primaryLight = Color(0xFF2A1F1F);
  static const Color primaryDark = Color(0xFF0A0808);

  // Secondary Colors
  static const Color secondary = Color(0xFF886364);
  static const Color secondaryLight = Color(0xFFA68A8A);
  static const Color secondaryDark = Color(0xFF6B4F4F);

  // Background Colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF4F0F0);
  static const Color backgroundDark = Color(0xFFE5E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF181111);
  static const Color textSecondary = Color(0xFF886364);
  static const Color textLight = Color(0xFFB8B0B0);
  static const Color textWhite = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE82630);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FC3F7);

  // Queue Status Colors
  static const Color queueActive = Color(0xFF4CAF50);
  static const Color queuePaused = Color(0xFFFFB74D);
  static const Color queueClosed = Color(0xFFE82630);
  static const Color queueCompleted = Color(0xFF4FC3F7);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF181111);
  static const Color buttonSecondary = Color(0xFFF4F0F0);
  static const Color buttonDisabled = Color(0xFFB8B0B0);

  // Border Colors
  static const Color borderLight = Color(0xFFF4F0F0);
  static const Color borderMedium = Color(0xFFE5E0E0);
  static const Color borderDark = Color(0xFFB8B0B0);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayMedium = Color(0xB3000000);
  static const Color overlayDark = Color(0xE6000000);

  // Category Colors
  static const Color categoryFood = Color(0xFFE57373);
  static const Color categoryFitness = Color(0xFF81C784);
  static const Color categoryBeauty = Color(0xFFF06292);
  static const Color categoryMedical = Color(0xFF4FC3F7);
  static const Color categoryGrocery = Color(0xFFFFB74D);
  static const Color categoryElectronics = Color(0xFF9575CD);
  static const Color categoryClothing = Color(0xFF4DB6AC);
  static const Color categoryHome = Color(0xFFA1887F);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF181111),
    Color(0xFF2A1F1F),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF886364),
    Color(0xFFA68A8A),
  ];

  // Material Color Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF181111,
    <int, Color>{
      50: Color(0xFFF3F2F2),
      100: Color(0xFFE7E5E5),
      200: Color(0xFFCFCBCB),
      300: Color(0xFFB7B1B1),
      400: Color(0xFF9F9797),
      500: Color(0xFF181111), // Primary color
      600: Color(0xFF130E0E),
      700: Color(0xFF0E0B0B),
      800: Color(0xFF0A0808),
      900: Color(0xFF050404),
    },
  );
}
