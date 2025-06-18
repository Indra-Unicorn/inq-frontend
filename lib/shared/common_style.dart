import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

/// CommonStyle provides a centralized place to manage all common styles used in the application.
/// Styles are organized by their type and usage.
class CommonStyle {
  // Private constructor to prevent instantiation
  CommonStyle._();

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.015,
  );

  static const TextStyle heading2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.015,
  );

  static const TextStyle heading3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.015,
  );

  static const TextStyle heading4 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.015,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.015,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.015,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.015,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.015,
  );

  // Button Styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.textWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary,
    foregroundColor: AppColors.textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
  );

  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  // Input Styles
  static final InputDecoration textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: AppColors.backgroundLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  // Card Styles
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Container Styles
  static final BoxDecoration containerDecoration = BoxDecoration(
    color: AppColors.backgroundLight,
    borderRadius: BorderRadius.circular(12),
  );

  // Divider Styles
  static const Divider defaultDivider = Divider(
    color: AppColors.borderLight,
    thickness: 1,
    height: 1,
  );

  // Chip Styles
  static final ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: AppColors.backgroundLight,
    labelStyle: bodyMedium,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );

  // List Tile Styles
  static final ListTileThemeData listTileTheme = ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    titleTextStyle: bodyMedium,
    subtitleTextStyle: caption,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // AppBar Styles
  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: heading4,
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),
  );

  // Bottom Navigation Bar Styles
  static final BottomNavigationBarThemeData bottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.secondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  );

  // Dialog Styles
  static final DialogTheme dialogTheme = DialogTheme(
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: heading4,
    contentTextStyle: bodyMedium,
  );

  // Snackbar Styles
  static final SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.primary,
    contentTextStyle: bodyMedium.copyWith(color: AppColors.textWhite),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  );

  // Progress Indicator Styles
  static const CircularProgressIndicator defaultProgressIndicator =
      CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    strokeWidth: 2,
  );

  // Error Styles
  static final TextStyle errorTextStyle = bodySmall.copyWith(
    color: AppColors.error,
  );

  // Success Styles
  static final TextStyle successTextStyle = bodySmall.copyWith(
    color: AppColors.success,
  );

  // Warning Styles
  static final TextStyle warningTextStyle = bodySmall.copyWith(
    color: AppColors.warning,
  );

  // Info Styles
  static final TextStyle infoTextStyle = bodySmall.copyWith(
    color: AppColors.info,
  );
}
