import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/merchant_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantService {
  Future<List<MerchantData>> getApprovedMerchants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/merchant/get/all?status=APPROVED'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => MerchantData.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch merchants');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to fetch merchants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
