import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../shared/constants/app_constants.dart';

class ProfileService {
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove(AppConstants.tokenKey);
    await prefs.clear();
  }
}
