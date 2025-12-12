import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../models/queue.dart';
import '../models/customer_queue_summary.dart';
import '../models/shop_queue_response.dart';

class QueueService {
  Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  Future<ShopQueueResponse> getShopQueues(String shopId) async {
    try {
      final token = await _getToken();
      
      final headers = <String, String>{
        'accept': '*/*',
      };
      
      // Add auth header only if token is available (for public viewing)
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/shop/$shopId'),
        headers: headers,
      );


      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return ShopQueueResponse.fromJson(jsonResponse);
      }
      
      // Extract the specific error message from API response
      final errorMessage = jsonResponse['message'] ?? 'Failed to load shop and queue data';
      throw Exception(errorMessage);
    } catch (e) {
      // Re-throw the original exception to preserve API error messages
      rethrow;
    }
  }

  Future<List<Queue>> getShopQueuesOnly(String shopId) async {
    final response = await getShopQueues(shopId);
    return response.queues;
  }

  Future<Map<String, dynamic>> joinQueue(String queueId,
      {String? comment}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/join'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'comment': comment,
        }),
      );


      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse['data'];
      }
      
      // Extract the specific error message from API response
      final errorMessage = jsonResponse['message'] ?? 'Failed to join queue';
      throw Exception(errorMessage);
    } catch (e) {
      // Re-throw the original exception to preserve API error messages
      rethrow;
    }
  }

  Future<CustomerQueueSummary> getCustomerQueueSummary() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/customer/summary'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return CustomerQueueSummary.fromJson(jsonResponse['data']);
        }
      }
      throw Exception('Failed to load customer queue summary');
    } catch (e) {
      throw Exception('Error fetching customer queue summary: $e');
    }
  }

  Future<http.Response> getLivePositionStream(String queueId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    return await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/live-position'),
      headers: {
        'Accept': 'text/event-stream',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
