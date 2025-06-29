import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../shared/constants/app_constants.dart';
import '../models/merchant_data.dart';

class MerchantDataService {
  static Future<MerchantData> getMerchantData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/merchant/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return MerchantData.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Failed to fetch merchant data');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching merchant data: $e');
    }
  }
}
