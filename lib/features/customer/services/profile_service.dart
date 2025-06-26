import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../services/auth_service.dart';

class ProfileService {
  Future<Map<String, dynamic>> getUserData() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final decodedToken = JwtDecoder.decode(token);
    final memberId = decodedToken['memberId'];

    if (memberId == null) {
      throw Exception('Invalid token');
    }

    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getUserById}/$memberId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load user data');
    }
  }

  Future<void> logout() async {
    await AuthService.clearAuthData();
  }

  Future<void> updateCustomerLocation(
      {double? latitude, double? longitude}) async {
    if (latitude == null || longitude == null) return;
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.patch(
      Uri.parse('${ApiEndpoints.baseUrl}/users/customer/location/update'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"latitude": $latitude, "longitude": $longitude}',
    );

    if (response.statusCode == 200) {
      final data = response.body;
      // Parse the response to get the location string
      final location =
          RegExp(r'"location"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
      if (location != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.locationKey, location);
      }
    } else {
      throw Exception('Failed to update location');
    }
  }
}
