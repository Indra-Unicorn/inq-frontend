import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../models/queue.dart';
import '../models/customer_queue_summary.dart';

class QueueService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token;
  }

  Future<List<Queue>> getShopQueues(String shopId) async {
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
          final List<dynamic> queuesData = jsonResponse['data'];
          return queuesData.map((queue) => Queue.fromJson(queue)).toList();
        }
      }
      throw Exception('Failed to load queues');
    } catch (e) {
      print('Error in getShopQueues: $e');
      throw Exception('Error fetching queues: $e');
    }
  }

  Future<Map<String, dynamic>> joinQueue(String queueId, {String? comment}) async {
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

      print('Customer Queue Summary API Response Status: ${response.statusCode}');
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