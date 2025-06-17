import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/shop.dart';

class ShopService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    print('Retrieved token: ${token != null ? 'Token exists' : 'No token found'}');
    return token;
  }

  Future<List<Shop>> getAllShops() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('Token is null, user not authenticated');
        throw Exception('User not authenticated');
      }

      print('Making API call with token: ${token.substring(0, 20)}...');
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/shops/get/all'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> shopsData = jsonResponse['data'];
          return shopsData.map((shop) => Shop.fromJson(shop)).toList();
        }
      }
      throw Exception('Failed to load shops');
    } catch (e) {
      print('Error in getAllShops: $e');
      throw Exception('Error fetching shops: $e');
    }
  }
} 