class AppConstants {
  static const String appName = 'Queue Management';
  static const String fcmTopic = 'queue_updates';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // User types
  static const String userTypeCustomer = 'CUSTOMER';
  static const String userTypeMerchant = 'MERCHANT';
  static const String userTypeAdmin = 'ADMIN';
  
  // Queue statuses
  static const String queueStatusActive = 'ACTIVE';
  static const String queueStatusPaused = 'PAUSED';
  static const String queueStatusClosed = 'CLOSED';
  
  // Merchant statuses
  static const String merchantStatusCreated = 'CREATED';
  static const String merchantStatusApproved = 'APPROVED';
  static const String merchantStatusBlocked = 'BLOCKED';
  
  // Device types
  static const String deviceTypeAndroid = 'ANDROID';
  static const String deviceTypeIOS = 'IOS';
  static const String deviceTypeWeb = 'WEB';
}

// lib/core/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Indian phone number validation
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateQueueName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Queue name is required';
    }
    if (value.length < 1 || value.length > 255) {
      return 'Queue name must be between 1 and 255 characters';
    }
    return null;
  }

  static String? validateMaxSize(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 1) {
      return 'Maximum size must be at least 1';
    }
    return null;
  }
}