import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../services/location_service.dart';

/// A helper widget that provides enhanced location permission handling
/// with user-friendly dialogs and retry mechanisms
class LocationPermissionHelper {
  static Future<String?> requestLocationWithDialog(BuildContext context) async {
    final result = await LocationService.getCurrentLocationWithStatus();
    
    if (result.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location obtained successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return result.location;
    } else {
      if (context.mounted) {
        await _showLocationErrorDialog(context, result);
      }
      return null;
    }
  }

  static Future<void> _showLocationErrorDialog(BuildContext context, LocationResult result) async {
    String title = 'Location Access Required';
    String content = result.message;
    List<Widget> actions = [];

    switch (result.error) {
      case LocationError.serviceDisabled:
        content = 'Location services are disabled on your device. Please enable location services to continue.';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Open Settings'),
          ),
        ];
        break;

      case LocationError.permissionDenied:
        content = 'This app needs location access to provide location-based features. Please allow location access when prompted.';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try again after user dismissed dialog
              Future.delayed(const Duration(milliseconds: 500), () {
                requestLocationWithDialog(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ];
        break;

      case LocationError.permissionDeniedForever:
        content = 'Location permissions have been permanently denied. Please enable location access in your device settings to continue.';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Open Settings'),
          ),
        ];
        break;

      case LocationError.timeout:
        content = 'Location request timed out. Please try again.';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              requestLocationWithDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ];
        break;

      case LocationError.unknown:
      default:
        content = 'An error occurred while getting your location. Please try again.';
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              requestLocationWithDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ];
        break;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: actions,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  /// Show an informational dialog about location usage
  static Future<void> showLocationInfoDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Usage',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app uses your location to:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildLocationUsageItem('📍 Set your shop location for customers to find you'),
              _buildLocationUsageItem('🗺️ Show nearby shops and services'),
              _buildLocationUsageItem('🎯 Provide location-based recommendations'),
              const SizedBox(height: 12),
              Text(
                'Your location is only used when needed and you can control permissions at any time in your device settings.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Got it'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  static Widget _buildLocationUsageItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.3,
        ),
      ),
    );
  }
}
