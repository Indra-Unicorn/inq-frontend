import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../models/merchant_queue.dart';
import '../../customer/models/customer_queue_summary.dart';

class MerchantQueueService {
  static Future<String?> _getAuthToken() async {
    final token = await AuthService.getToken();
    return token;
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

  static Future<void> processNextCustomer(String queueId, String customerId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/queue-manager/$queueId/processCustomer/$customerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
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
    await _updateQueueStatus(queueId, 'PAUSED');
  }

  static Future<void> resumeQueue(String queueId) async {
    await _updateQueueStatus(queueId, 'ACTIVE');
  }

  static Future<void> stopQueue(String queueId) async {
    await _updateQueueStatus(queueId, 'CLOSED');
  }

  /// Update queue status using the unified status endpoint
  static Future<void> _updateQueueStatus(String queueId, String status) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/queues/$queueId/status?status=$status'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      // Handle both success response formats
      if (response.statusCode == 200) {
        // API might return success without JSON body or with JSON body
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            if (data['success'] == false) {
              throw Exception(data['message'] ?? 'Failed to update queue status');
            }
          } catch (e) {
            // If JSON parsing fails but status is 200, consider it successful
            if (e is! Exception || !e.toString().contains('Failed to update')) {
              // JSON parsing error is acceptable for 200 status
            } else {
              rethrow;
            }
          }
        }
      } else {
        String errorMessage = 'Failed to update queue status';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (e) {
          // Use default error message if JSON parsing fails
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to update queue status to $status: $e');
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

  static Future<void> removeCustomer(String queueId, String customerId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/queue-manager/$queueId/members/$customerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to remove customer');
      }
    } catch (e) {
      throw Exception('Failed to remove customer: $e');
    }
  }
}
