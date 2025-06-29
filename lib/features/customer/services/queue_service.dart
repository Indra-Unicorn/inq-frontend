import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_constants.dart';
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

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return ShopQueueResponse.fromJson(jsonResponse);
        }
      }
      throw Exception('Failed to load shop and queue data');
    } catch (e) {
      print('Error in getShopQueues: $e');
      throw Exception('Error fetching shop and queue data: $e');
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

      print('Join Queue API Response Status: ${response.statusCode}');
      print('Join Queue API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
      }
      throw Exception('Failed to join queue');
    } catch (e) {
      print('Error in joinQueue: $e');
      throw Exception('Error joining queue: $e');
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

      print(
          'Customer Queue Summary API Response Status: ${response.statusCode}');
      print('Customer Queue Summary API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return CustomerQueueSummary.fromJson(jsonResponse['data']);
        }
      }
      throw Exception('Failed to load customer queue summary');
    } catch (e) {
      print('Error in getCustomerQueueSummary: $e');
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
