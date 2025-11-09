import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../common_style.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              title,
              style: CommonStyle.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: CommonStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText ?? 'Okay',
                  style: CommonStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error dialog with default styling
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onPressed: onPressed,
        );
      },
    );
  }

  /// Show a generic error dialog for API failures
  static Future<void> showApiError(
    BuildContext context, {
    String? customMessage,
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      title: 'Something went wrong',
      message: customMessage ?? 
          'We encountered an unexpected error. Please try again later.',
      buttonText: 'Okay',
      onPressed: onPressed,
    );
  }

  /// Show error dialog for network issues
  static Future<void> showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      buttonText: onRetry != null ? 'Retry' : 'Okay',
      onPressed: onRetry ?? () => Navigator.of(context).pop(),
    );
  }

  /// Show error dialog for authentication issues
  static Future<void> showAuthError(
    BuildContext context, {
    VoidCallback? onLogin,
  }) {
    return show(
      context,
      title: 'Authentication Required',
      message: 'Please log in to continue using the app.',
      buttonText: 'Login',
      onPressed: onLogin ?? () {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  /// Extract user-friendly message from error
  static String getErrorMessage(dynamic error) {
    String errorString = error.toString();
    
    // Remove common prefixes to get the actual message
    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.substring(11);
    }
    if (errorString.startsWith('Error: ')) {
      errorString = errorString.substring(7);
    }
    
    // Don't modify API error messages - they're already user-friendly
    // Check if it looks like an API error message (no technical prefixes)
    if (!errorString.contains('SocketException') &&
        !errorString.contains('TimeoutException') &&
        !errorString.contains('FormatException') &&
        !errorString.contains('Connection refused') &&
        !errorString.contains('Network is unreachable') &&
        !errorString.startsWith('Error fetching') &&
        !errorString.startsWith('Failed to') &&
        errorString.isNotEmpty) {
      // This looks like a clean API message, return as-is
      return errorString;
    }
    
    // Remove more technical prefixes for non-API errors
    if (errorString.startsWith('Error fetching ')) {
      errorString = errorString.substring(15);
    }
    if (errorString.startsWith('Failed to ')) {
      errorString = errorString.substring(10);
    }
    
    // Handle specific technical error patterns
    if (errorString.contains('SocketException') || 
        errorString.contains('Connection refused') ||
        errorString.contains('Network is unreachable')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    
    if (errorString.contains('TimeoutException') ||
        errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('FormatException') ||
        errorString.contains('Invalid')) {
      return 'Received invalid data from server. Please try again.';
    }
    
    if (errorString.contains('User not authenticated') ||
        errorString.contains('Authentication required')) {
      return 'Please log in to continue.';
    }
    
    // Return cleaned message or default
    return errorString.isNotEmpty ? errorString : 'An unexpected error occurred.';
  }
}
