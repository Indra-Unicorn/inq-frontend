import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import '../shared/constants/app_constants.dart';
import '../shared/constants/api_endpoints.dart';

class AuthService {
  // Use AppConstants keys for consistency
  static const String _tokenKey = AppConstants.tokenKey;
  static const String _userDataKey = AppConstants.userKey;
  static const String _loginTimeKey = AppConstants.loginTimeKey;
  static const String _refreshTokenKey = AppConstants.refreshTokenKey;

  // Store authentication data
  static Future<void> storeAuthData({
    required String token,
    required Map<String, dynamic> userData,
    String? refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store token
      await prefs.setString(_tokenKey, token);

      // Store user data
      await prefs.setString(_userDataKey, jsonEncode(userData));

      // Store login time
      await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());

      // Store refresh token if provided
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      throw Exception('Failed to store authentication data');
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null) {
        // Check if token is expired
        if (await _isTokenExpired(token)) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            final refreshedToken = prefs.getString(_tokenKey);
            return refreshedToken;
          } else {
            // Token expired and couldn't refresh, clear stored data
            await clearAuthData();
            return null;
          }
        }
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  // Check if token is expired
  static Future<bool> _isTokenExpired(String token) async {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expirationTime =
          DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      final currentTime = DateTime.now();

      // Consider token expired if it expires within the next 5 minutes
      return currentTime
          .isAfter(expirationTime.subtract(const Duration(minutes: 5)));
    } catch (e) {
      return false; // If we can't decode, assume it's valid
    }
  }

  // Refresh token
  static Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Store new token
          await prefs.setString(_tokenKey, data['data']['token']);

          // Store new refresh token if provided
          if (data['data']['refreshToken'] != null) {
            await prefs.setString(
                _refreshTokenKey, data['data']['refreshToken']);
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_loginTimeKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
    }
  }

  // Get user type from stored data with JWT fallback
  static Future<String?> getUserType() async {
    try {
      final userData = await getUserData();
      
      // Check if userData is empty or missing userType
      if (userData == null || userData.isEmpty || userData['userType'] == null) {
        // Extract user type directly from JWT token
        return await _getUserTypeFromJWT();
      }
      
      return userData['userType'];
    } catch (e) {
      return null;
    }
  }

  // Get user ID from stored data
  static Future<String?> getUserId() async {
    try {
      final userData = await getUserData();
      return userData?['memberId']?.toString();
    } catch (e) {
      return null;
    }
  }

  // Validate token locally (JWT-based validation only)
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  // Get login time
  static Future<DateTime?> getLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimeString = prefs.getString(_loginTimeKey);

      if (loginTimeString != null) {
        return DateTime.parse(loginTimeString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Extract user type from JWT token
  static Future<String?> _getUserTypeFromJWT() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final decodedToken = JwtDecoder.decode(token);
      
      // Try different possible keys for user type in JWT
      final userType = decodedToken['userType'] ?? 
                      decodedToken['user_type'] ?? 
                      decodedToken['type'] ??
                      decodedToken['role'];
      
      return userType?.toString();
    } catch (e) {
      return null;
    }
  }

}
