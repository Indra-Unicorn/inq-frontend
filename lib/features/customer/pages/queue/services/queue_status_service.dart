import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../../../shared/constants/api_endpoints.dart';
import '../../../../../services/auth_service.dart';
import '../../../models/customer_queue_summary.dart';
import 'polling_config.dart';

class QueueStatusService {
  static Future<CustomerQueueSummary> fetchQueueData() async {
    final token = await AuthService.getToken();

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
    final token = await AuthService.getToken();

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

  // Unified polling method that uses the configured strategy
  static Stream<CustomerQueue> pollQueuePosition(String queueId) async* {
    switch (PollingConfig.strategy) {
      case PollingStrategy.shortPolling:
        yield* _shortPollQueuePosition(queueId);
        break;
      case PollingStrategy.longPolling:
        yield* _longPollQueuePosition(queueId);
        break;
      case PollingStrategy.hybridPolling:
        yield* _hybridPollQueuePosition(queueId);
        break;
      case PollingStrategy.adaptivePolling:
        yield* _adaptivePollQueuePosition(queueId);
        break;
    }
  }

  // Short polling implementation
  static Stream<CustomerQueue> _shortPollQueuePosition(String queueId) async* {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    while (true) {
      try {
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/position'),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: PollingConfig.getTimeout()));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final queueData = CustomerQueue.fromJson(jsonResponse['data']);
            yield queueData;
          } else {
            throw Exception(
                jsonResponse['message'] ?? 'Failed to fetch position');
          }
        } else {
          throw Exception('Failed to fetch position: ${response.statusCode}');
        }

        // Wait for configured interval
        await Future.delayed(
            Duration(seconds: PollingConfig.getMinDelayBetweenRequests()));
      } catch (e) {
        if (PollingConfig.enableLogging) {
        }
        await Future.delayed(
            Duration(seconds: PollingConfig.getErrorRetryDelay()));
        rethrow;
      }
    }
  }

  // Long polling implementation
  static Stream<CustomerQueue> _longPollQueuePosition(String queueId) async* {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    while (true) {
      try {
        // Long poll request - server holds connection until data changes or timeout
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/position'),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: PollingConfig.getTimeout()));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final queueData = CustomerQueue.fromJson(jsonResponse['data']);
            yield queueData;
            // No delay - immediately make next request
          } else {
            throw Exception(
                jsonResponse['message'] ?? 'Failed to fetch position');
          }
        } else {
          throw Exception('Failed to fetch position: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          // Timeout is normal for long polling - just retry immediately
          continue;
        } else {
          if (PollingConfig.enableLogging) {
          }
          await Future.delayed(
              Duration(seconds: PollingConfig.getErrorRetryDelay()));
          rethrow;
        }
      }
    }
  }

  // Hybrid polling implementation
  static Stream<CustomerQueue> _hybridPollQueuePosition(String queueId) async* {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    while (true) {
      try {
        // Long poll request with timeout - server holds connection until data changes or timeout
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/position'),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: PollingConfig.getTimeout()));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final queueData = CustomerQueue.fromJson(jsonResponse['data']);
            yield queueData;

            // Minimum delay between requests to prevent overwhelming the server
            await Future.delayed(
                Duration(seconds: PollingConfig.getMinDelayBetweenRequests()));
          } else {
            throw Exception(
                jsonResponse['message'] ?? 'Failed to fetch position');
          }
        } else {
          throw Exception('Failed to fetch position: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          // Timeout is normal for long polling - just retry after minimum delay
          await Future.delayed(
              Duration(seconds: PollingConfig.getMinDelayBetweenRequests()));
        } else {
          if (PollingConfig.enableLogging) {
          }
          // Other errors - wait longer before retry
          await Future.delayed(
              Duration(seconds: PollingConfig.getErrorRetryDelay()));
          rethrow;
        }
      }
    }
  }

  // Legacy method for backward compatibility
  static Stream<CustomerQueue> hybridPollQueuePosition(String queueId) async* {
    yield* _hybridPollQueuePosition(queueId);
  }

  // Adaptive polling implementation
  static Stream<CustomerQueue> _adaptivePollQueuePosition(
      String queueId) async* {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    int lastPosition = -1; // Track last known position

    while (true) {
      try {
        // Long poll request with timeout - server holds connection until data changes or timeout
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$queueId/position'),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: PollingConfig.getTimeout()));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final queueData = CustomerQueue.fromJson(jsonResponse['data']);
            yield queueData;

            // Calculate adaptive delay based on current position
            final currentPosition = queueData.currentRank ?? 0;
            final adaptiveDelay =
                PollingConfig.getAdaptiveDelay(currentPosition);

            if (PollingConfig.enableLogging &&
                currentPosition != lastPosition) {
              // Queue position changed, updating delay
              lastPosition = currentPosition;
            }

            // Apply adaptive delay
            if (adaptiveDelay > 0) {
              await Future.delayed(Duration(seconds: adaptiveDelay));
            }
          } else {
            throw Exception(
                jsonResponse['message'] ?? 'Failed to fetch position');
          }
        } else {
          throw Exception('Failed to fetch position: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          // Timeout is normal for long polling - just retry after minimum delay
          await Future.delayed(Duration(seconds: 1)); // Small delay on timeout
        } else {
          if (PollingConfig.enableLogging) {
          }
          // Other errors - wait longer before retry
          await Future.delayed(
              Duration(seconds: PollingConfig.getErrorRetryDelay()));
          rethrow;
        }
      }
    }
  }
}
