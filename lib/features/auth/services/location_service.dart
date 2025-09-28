import 'package:geolocator/geolocator.dart';

// Service class for location operations
class LocationService {
  // Enhanced location result with detailed status
  static Future<LocationResult> getCurrentLocationWithStatus() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          location: null,
          error: LocationError.serviceDisabled,
          message: 'Location services are disabled. Please enable location services in your device settings.',
        );
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            location: null,
            error: LocationError.permissionDenied,
            message: 'Location permission was denied. Please allow location access to continue.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          location: null,
          error: LocationError.permissionDeniedForever,
          message: 'Location permissions are permanently denied. Please enable location access in your device settings.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return LocationResult(
        success: true,
        location: '${position.latitude},${position.longitude}',
        error: null,
        message: 'Location obtained successfully',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
      return LocationResult(
        success: false,
        location: null,
        error: LocationError.unknown,
        message: 'Failed to get location: ${e.toString()}',
      );
    }
  }

  // Legacy method for backwards compatibility
  static Future<String?> getCurrentLocation() async {
    final result = await getCurrentLocationWithStatus();
    return result.location;
  }

  // Open device settings for location permissions
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

// Enhanced result class for location operations
class LocationResult {
  final bool success;
  final String? location;
  final LocationError? error;
  final String message;
  final double? latitude;
  final double? longitude;

  LocationResult({
    required this.success,
    required this.location,
    required this.error,
    required this.message,
    this.latitude,
    this.longitude,
  });
}

// Location error types
enum LocationError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}
