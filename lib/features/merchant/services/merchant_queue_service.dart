import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../models/merchant_queue.dart';
import '../../customer/models/customer_queue_summary.dart';

class MerchantQueueService {
  static Future<String?> _getAuthToken() async {
    return await AuthService.getToken();
  }

  static Future<List<MerchantQueue>> getMerchantQueues() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/merchant'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> queuesData = data['data'] ?? [];
        return queuesData.map((json) => MerchantQueue.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load queues');
      }
    } catch (e) {
      throw Exception('Failed to load queues: $e');
    }
  }

  static Future<MerchantQueue> getQueueDetails(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/$queueId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return MerchantQueue.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load queue details');
      }
    } catch (e) {
      throw Exception('Failed to load queue details: $e');
    }
  }

  static Future<void> processNextCustomer(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/queue-manager/$queueId/process-next'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to process next customer');
      }
    } catch (e) {
      throw Exception('Failed to process next customer: $e');
    }
  }

  static Future<MerchantQueue> createQueue({
    required String name,
    required int maxSize,
    required double inQoinRate,
    required int alertNumber,
    required int bufferNumber,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'maxSize': maxSize,
          'inQoinRate': inQoinRate,
          'alertNumber': alertNumber,
          'bufferNumber': bufferNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return MerchantQueue.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create queue');
      }
    } catch (e) {
      throw Exception('Failed to create queue: $e');
    }
  }

  static Future<void> pauseQueue(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/pause'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to pause queue');
      }
    } catch (e) {
      throw Exception('Failed to pause queue: $e');
    }
  }

  static Future<void> resumeQueue(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/resume'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to resume queue');
      }
    } catch (e) {
      throw Exception('Failed to resume queue: $e');
    }
  }

  static Future<void> stopQueue(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/stop'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to stop queue');
      }
    } catch (e) {
      throw Exception('Failed to stop queue: $e');
    }
  }

  static Future<void> deleteQueue(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/$queueId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to delete queue');
      }
    } catch (e) {
      throw Exception('Failed to delete queue: $e');
    }
  }

  static Future<List<CustomerQueue>> getQueueMembers(String queueId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/members'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> membersData = data['data'] ?? [];
        return membersData.map((json) => CustomerQueue.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load queue members');
      }
    } catch (e) {
      throw Exception('Failed to load queue members: $e');
    }
  }
}
