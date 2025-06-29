import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

/// CommonStyle provides a centralized place to manage all common styles used in the application.
/// Styles are organized by their type and usage.
class CommonStyle {
  // Private constructor to prevent instantiation
  CommonStyle._();

  // Typography
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.4,
  );

  // Button Styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.primary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Card Styles
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.backgroundLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Input Styles
  static final InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
