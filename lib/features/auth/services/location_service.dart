import 'package:geolocator/geolocator.dart';

// Service class for location operations
class LocationService {
  static Future<String?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}
