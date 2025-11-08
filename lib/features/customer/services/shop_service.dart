import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../models/shop.dart';

class ShopService {
  Future<String?> _getToken() async {
    final token = await AuthService.getToken();
    print(
        'Retrieved token: ${token != null ? 'Token exists' : 'No token found'}');
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

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final List<dynamic> shopsData = jsonResponse['data'];
        return shopsData.map((shop) => Shop.fromJson(shop)).toList();
      }
      
      // Extract the specific error message from API response
      final errorMessage = jsonResponse['message'] ?? 'Failed to load shops';
      throw Exception(errorMessage);
    } catch (e) {
      print('Error in getAllShops: $e');
      // Re-throw the original exception to preserve API error messages
      rethrow;
    }
  }

  Future<List<Shop>> searchShops({
    required String search,
    double? latitude,
    double? longitude,
    int? radiusKm,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }
      
      // Build query parameters
      final queryParams = <String, String>{
        'shopName': search,
        'radiusKm': (radiusKm ?? AppConstants.searchRadiusKm).toString(),
      };
      
      // Add location parameters if available
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude.toString();
        queryParams['longitude'] = longitude.toString();
      }
      
      // Build URI with query parameters
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/users/nearby')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          data = decoded['data'];
        } else {
          data = [];
        }
        return data
            .where((shop) => shop != null && shop is Map<String, dynamic>)
            .take(10)
            .map((shop) => Shop.fromJson(shop as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to search shops');
    } catch (e) {
      throw Exception('Error searching shops: $e');
    }
  }

  Future<Shop> getShopById(String shopId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/shop/$shopId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return Shop.fromJson(jsonResponse['data']);
      }
      
      // Extract the specific error message from API response
      final errorMessage = jsonResponse['message'] ?? 'Failed to load shop details';
      throw Exception(errorMessage);
    } catch (e) {
      print('Error in getShopById: $e');
      // Re-throw the original exception to preserve API error messages
      rethrow;
    }
  }
}
