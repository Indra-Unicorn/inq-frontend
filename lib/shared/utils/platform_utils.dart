import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform utility class that provides safe platform information
/// across different environments (mobile, web, desktop)
class PlatformUtils {
  /// Get device type safely across all platforms
  static String getDeviceType() {
    if (kIsWeb) {
      return 'WEB';
    }
    
    try {
      if (Platform.isAndroid) {
        return 'ANDROID';
      } else if (Platform.isIOS) {
        return 'IOS';
      } else if (Platform.isMacOS) {
        return 'MACOS';
      } else if (Platform.isWindows) {
        return 'WINDOWS';
      } else if (Platform.isLinux) {
        return 'LINUX';
      } else {
        return 'UNKNOWN';
      }
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  /// Get operating system version safely
  static String getOSVersion() {
    if (kIsWeb) {
      return 'Web Browser';
    }
    
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get a safe device model identifier
  static String getDeviceModel() {
    if (kIsWeb) {
      return 'Web Browser';
    }
    
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Check if running on mobile platform
  static bool get isMobile {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Check if running on desktop platform
  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    } catch (e) {
      return false;
    }
  }

  /// Get app version (this should be updated when you have actual version management)
  static String getAppVersion() {
    return '1.0.0';
  }

  /// Get platform-specific metadata for API calls
  static Map<String, dynamic> getPlatformMetadata() {
    return {
      'deviceType': getDeviceType(),
      'appVersion': getAppVersion(),
      'osVersion': getOSVersion(),
      'platform': kIsWeb ? 'web' : 'mobile',
    };
  }
}
