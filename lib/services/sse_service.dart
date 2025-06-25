import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/constants/app_constants.dart';
import '../shared/constants/api_endpoints.dart';
import '../models/queue_member_response.dart';

class SSEService {
  static final SSEService _instance = SSEService._internal();
  factory SSEService() => _instance;
  SSEService._internal();

  StreamController<QueueMemberResponse>? _eventController;
  StreamSubscription? _subscription;
  Timer? _pollingTimer;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _isConnected = false;
  bool _isDisposed = false;
  String? _currentQueueId;
  String? _currentToken;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _pollingInterval = Duration(seconds: 60); // 60 seconds as requested
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  Stream<QueueMemberResponse>? get eventStream => _eventController?.stream;

  Future<void> connectToQueueStream(String queueId) async {
    if (_isDisposed) return;
    
    _currentQueueId = queueId;
    
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    
    _currentToken = token;
    
    // Try SSE connection first
    await _trySSEConnection();
    
    // If SSE fails, fall back to polling
    if (!_isConnected) {
      print('SSE connection failed, falling back to polling');
      _startPolling();
    }
  }

  Future<void> _trySSEConnection() async {
    if (_isDisposed || _currentQueueId == null || _currentToken == null) return;

    try {
      print('Attempting SSE connection for queue: $_currentQueueId');
      
      // Initialize event controller
      _eventController = StreamController<QueueMemberResponse>.broadcast();
      
      // Create HTTP client with timeout
      final client = http.Client();
      
      // Replace {queueId} placeholder with actual queue ID
      final endpoint = ApiEndpoints.streamLivePosition.replaceAll('{queueId}', _currentQueueId!);
      
      final request = http.Request(
        'GET',
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      );
      
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Authorization': 'Bearer $_currentToken',
        'Connection': 'keep-alive',
      });

      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Connection timeout', const Duration(seconds: 30));
        },
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception('SSE connection failed: ${streamedResponse.statusCode}');
      }

      print('SSE connection established successfully');
      _isConnected = true;
      _reconnectAttempts = 0;

      // Start heartbeat timer
      _startHeartbeat();

      // Process SSE stream
      _subscription = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (_isDisposed) return;
          
          print('SSE raw line: $line'); // Debug line
          
          if (line.startsWith('data: ')) {
            try {
              final jsonStr = line.substring(6).trim();
              if (jsonStr.isEmpty) return;
              
              print('Received SSE data: $jsonStr');
              
              // Handle malformed data with double "data:" prefix
              String actualJsonStr = jsonStr;
              if (jsonStr.startsWith('data:')) {
                actualJsonStr = jsonStr.substring(5).trim();
              }
              
              if (actualJsonStr.isEmpty) return;
              
              final data = json.decode(actualJsonStr);
              
              // Check for error in SSE data
              if (data['error'] != null) {
                print('SSE error: ${data['error']}');
                _handleSSEError(data['error']);
                return;
              }
              
              // Parse the queue data using the model
              final queueMember = QueueMemberResponse.fromJson(data);
              print('Successfully parsed SSE queue data: ${queueMember.toString()}');
              if (_eventController != null && !_eventController!.isClosed) {
                _eventController!.add(queueMember);
              }
              
              // Check if queue is completed
              if (queueMember.isCompleted) {
                print('Queue completed via SSE, showing completion state');
                if (_eventController != null && !_eventController!.isClosed) {
                  _eventController!.add(QueueMemberResponse(
                    positionOffset: queueMember.positionOffset,
                    joinedPosition: queueMember.joinedPosition,
                    currentRank: queueMember.currentRank,
                    inQoinCharged: queueMember.inQoinCharged,
                    currentQueueSize: queueMember.currentQueueSize,
                    processed: queueMember.processed,
                    queueName: queueMember.queueName,
                    status: 'completed',
                    message: 'Your turn has arrived!',
                    timestamp: DateTime.now().toIso8601String(),
                  ));
                }
                _disconnect();
              }
              
            } catch (e) {
              print('Error parsing SSE data: $e');
            }
          } else if (line.startsWith(':')) {
            // Comment line, ignore
            print('SSE comment line: $line');
            return;
          } else if (line.trim().isEmpty) {
            // Empty line, ignore
            return;
          } else {
            // Try to parse as regular JSON (in case it's not in SSE format)
            try {
              print('Trying to parse as regular JSON: $line');
              
              // Handle malformed data with "data:" prefix
              String actualJsonStr = line;
              if (line.startsWith('data:')) {
                actualJsonStr = line.substring(5).trim();
              }
              
              if (actualJsonStr.isEmpty) return;
              
              final data = json.decode(actualJsonStr);
              final queueMember = QueueMemberResponse.fromJson(data);
              print('Successfully parsed JSON fallback queue data: ${queueMember.toString()}');
              if (_eventController != null && !_eventController!.isClosed) {
                _eventController!.add(queueMember);
              }
              
              if (queueMember.isCompleted) {
                print('Queue completed via JSON, showing completion state');
                if (_eventController != null && !_eventController!.isClosed) {
                  _eventController!.add(QueueMemberResponse(
                    positionOffset: queueMember.positionOffset,
                    joinedPosition: queueMember.joinedPosition,
                    currentRank: queueMember.currentRank,
                    inQoinCharged: queueMember.inQoinCharged,
                    currentQueueSize: queueMember.currentQueueSize,
                    processed: queueMember.processed,
                    queueName: queueMember.queueName,
                    status: 'completed',
                    message: 'Your turn has arrived!',
                    timestamp: DateTime.now().toIso8601String(),
                  ));
                }
                _disconnect();
              }
            } catch (e) {
              print('Failed to parse as JSON: $e');
            }
          }
        },
        onError: (error) {
          print('SSE stream error: $error');
          _handleSSEError(error);
        },
        onDone: () {
          print('SSE stream closed');
          _handleSSEDisconnection();
        },
      );

    } catch (e) {
      print('SSE connection failed: $e');
      _handleSSEError(e);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isDisposed || !_isConnected) {
        timer.cancel();
        return;
      }
      
      // Send a heartbeat event to keep connection alive
      // Note: We don't send heartbeat events through the main stream
      // as they're not actual queue data
    });
  }

  void _handleSSEError(dynamic error) {
    print('Handling SSE error: $error');
    _isConnected = false;
    _subscription?.cancel();
    _heartbeatTimer?.cancel();
    
    // Try to reconnect if we haven't exceeded max attempts
    if (_reconnectAttempts < _maxReconnectAttempts && !_isDisposed) {
      _reconnectAttempts++;
      print('Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay, () {
        if (!_isDisposed) {
          _trySSEConnection();
        }
      });
    } else {
      // Fall back to polling
      print('Max reconnection attempts reached, falling back to polling');
      _startPolling();
    }
  }

  void _handleSSEDisconnection() {
    print('SSE disconnected');
    _isConnected = false;
    _subscription?.cancel();
    _heartbeatTimer?.cancel();
    
    // Try to reconnect
    if (!_isDisposed && _reconnectAttempts < _maxReconnectAttempts) {
      _handleSSEError('Connection lost');
    }
  }

  void _startPolling() {
    if (_isDisposed || _currentToken == null) return;
    
    print('Starting polling with ${_pollingInterval.inSeconds} second interval');
    
    // Cancel any existing polling
    _pollingTimer?.cancel();
    
    // Ensure event controller is initialized
    if (_eventController == null) {
      _eventController = StreamController<QueueMemberResponse>.broadcast();
    }
    
    // Start polling
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      try {
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/customer/summary'),
          headers: {
            'Accept': '*/*',
            'Authorization': 'Bearer $_currentToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            final List<dynamic> customerQueues = jsonResponse['data']['customerQueues'];
            final currentQueue = customerQueues.firstWhere(
              (queue) => queue['qid'] == _currentQueueId,
              orElse: () => null,
            );
            
            if (currentQueue != null) {
              final queueMember = QueueMemberResponse.fromJson(currentQueue);
              print('Successfully parsed polling queue data: ${queueMember.toString()}');
              if (_eventController != null && !_eventController!.isClosed) {
                _eventController!.add(queueMember);
              }
              
              // Check if queue is completed
              if (queueMember.isCompleted) {
                print('Queue completed via polling, showing completion state');
                if (_eventController != null && !_eventController!.isClosed) {
                  _eventController!.add(QueueMemberResponse(
                    positionOffset: queueMember.positionOffset,
                    joinedPosition: queueMember.joinedPosition,
                    currentRank: queueMember.currentRank,
                    inQoinCharged: queueMember.inQoinCharged,
                    currentQueueSize: queueMember.currentQueueSize,
                    processed: queueMember.processed,
                    queueName: queueMember.queueName,
                    status: 'completed',
                    message: 'Your turn has arrived!',
                    timestamp: DateTime.now().toIso8601String(),
                  ));
                }
                _disconnect();
              }
            } else {
              // Customer is no longer in active queues - check if they were processed
              final List<dynamic> customerPastQueues = jsonResponse['data']['customerPastQueues'];
              final processedQueue = customerPastQueues.firstWhere(
                (queue) => queue['qid'] == _currentQueueId && queue['wasProcessed'] == true,
                orElse: () => null,
              );
              
              if (processedQueue != null) {
                // Customer was processed - show completion
                print('Customer was processed, showing completion state');
                if (_eventController != null && !_eventController!.isClosed) {
                  _eventController!.add(QueueMemberResponse(
                    positionOffset: 0,
                    joinedPosition: _parseInt(processedQueue['joinedPosition']),
                    currentRank: 0,
                    inQoinCharged: _parseDouble(processedQueue['inQoinCharged']),
                    currentQueueSize: 0,
                    processed: 1,
                    queueName: processedQueue['queueName'],
                    status: 'completed',
                    message: 'Your turn has arrived!',
                    timestamp: DateTime.now().toIso8601String(),
                    comment: processedQueue['joinComment'],
                  ));
                }
                
                // Add a small delay before disconnecting to ensure the UI updates
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!_isDisposed) {
                    _disconnect();
                  }
                });
              } else {
                // Customer is not in active queues but also not processed - might have left
                print('Customer not found in active or processed queues - might have left');
                if (_eventController != null && !_eventController!.isClosed) {
                  _eventController!.add(QueueMemberResponse(
                    positionOffset: 0,
                    joinedPosition: 0,
                    currentRank: 0,
                    inQoinCharged: 0.0,
                    currentQueueSize: 0,
                    processed: 0,
                    queueName: 'Unknown',
                    status: 'left',
                    message: 'You have left the queue',
                    timestamp: DateTime.now().toIso8601String(),
                  ));
                }
                _disconnect();
              }
            }
          }
        }
      } catch (e) {
        print('Polling error: $e');
        // Don't stop polling on error, just log it
      }
    });
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value == "Infinity" || value == "infinity") return 999999;
      return int.tryParse(value) ?? 0;
    }
    return value as int;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return value as double;
  }

  void _disconnect() {
    print('Disconnecting SSE service');
    _isConnected = false;
    _subscription?.cancel();
    _pollingTimer?.cancel();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _eventController?.close();
    _isDisposed = true;
  }

  void dispose() {
    print('Disposing SSE service');
    _disconnect();
  }

  bool get isConnected => _isConnected;
  bool get isDisposed => _isDisposed;
} 