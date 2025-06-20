import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../../../shared/constants/api_endpoints.dart';
import '../../../models/customer_queue_summary.dart';

class QueueStatusService {
  static Future<CustomerQueueSummary> fetchQueueData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    if (token == null) {
      throw Exception('Authentication token not found');
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
      } else {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch queue data');
      }
    } else {
      throw Exception('Failed to fetch queue data: ${response.statusCode}');
    }
  }

  static Future<String> leaveQueue(String queueId, String leaveReason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/leave'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'leaveReason': leaveReason,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['data'] ?? 'Successfully left the queue';
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to leave queue');
      }
    } else {
      throw Exception('Failed to leave queue: ${response.statusCode}');
    }
  }
}
