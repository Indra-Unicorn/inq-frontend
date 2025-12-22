import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../../merchant/models/merchant_data.dart';

class AdminMerchantService {
  // Fetch all merchants by status
  static Future<List<MerchantData>> getAllMerchants(String status) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllMerchants}?status=$status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final merchantsList = data['data'] as List<dynamic>;
          return merchantsList
              .map((merchant) => MerchantData.fromJson(merchant))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch merchants');
        }
      } else {
        throw Exception('Failed to fetch merchants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching merchants: $e');
    }
  }

  // Update merchant status
  static Future<MerchantData> updateMerchantStatus(
    String merchantId,
    String status,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.updateMerchantStatusById(merchantId)}?status=$status',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MerchantData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to update merchant status');
        }
      } else {
        throw Exception('Failed to update merchant status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating merchant status: $e');
    }
  }
}

