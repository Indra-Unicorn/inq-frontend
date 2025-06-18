import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/api_endpoints.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage> {
  StreamController<Map<String, dynamic>>? _eventController;
  StreamSubscription? _subscription;
  Timer? _pollingTimer;
  Map<String, dynamic>? _queueData;
  bool _isLoading = true;
  String? _error;
  bool _isCompleted = false;
  bool _isInitialized = false;
  String? _queueId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeSSE();
      _isInitialized = true;
    }
  }

  Future<void> _initializeSSE() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null) {
        setState(() {
          _error = 'Invalid arguments';
          _isLoading = false;
        });
        return;
      }

      _queueId = args['queueId'] as String?;
      if (_queueId == null) {
        setState(() {
          _error = 'Queue ID not found';
          _isLoading = false;
        });
        return;
      }

      // Initialize with passed queue data
      setState(() {
        _queueData = _processQueueData(args['queueData'] as Map<String, dynamic>?);
        _isLoading = false;
      });

      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      print('Retrieved token: $token'); // Debug print
      
      if (token == null) {
        setState(() {
          _error = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      print('Connecting to SSE stream for queue: $_queueId');
      print('Using token: $token');

      // Try SSE connection first
      await _trySSEConnection(token);
      
      // If SSE fails, fall back to polling
      if (_subscription == null) {
        print('SSE connection failed, falling back to polling');
        _startPolling(token);
      }

    } catch (e) {
      print('Error in _initializeSSE: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _trySSEConnection(String token) async {
    try {
      // Initialize SSE connection
      _eventController = StreamController<Map<String, dynamic>>();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/queue-manager/$_queueId/live-position'),
        headers: {
          'Accept': 'text/event-stream',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to connect to SSE stream: ${response.statusCode}');
      }

      print('SSE connection established');

      // Process SSE stream
      _subscription = Stream.fromIterable(response.body.split('\n')).listen((line) {
        if (line.startsWith('data: ')) {
          try {
            final jsonStr = line.substring(6);
            print('Received SSE data: $jsonStr');
            final data = json.decode(jsonStr);
            
            if (data['status'] == 'completed') {
              _eventController?.add({
                'status': 'completed',
                'message': data['message'],
                'timestamp': data['timestamp'],
              });
              _isCompleted = true;
            } else {
              // Process the queue data to handle type conversions
              final Map<String, dynamic> processedData = _processQueueData(data);
              _eventController?.add(processedData);
            }
          } catch (e) {
            print('Error parsing SSE data: $e');
          }
        }
      });

      // Listen to SSE events
      _eventController?.stream.listen((data) {
        if (mounted) {
          setState(() {
            _queueData = data;
            if (data['status'] == 'completed') {
              _isCompleted = true;
            }
          });
        }
      });

    } catch (e) {
      print('SSE connection failed: $e');
      _subscription?.cancel();
      _eventController?.close();
      _subscription = null;
      _eventController = null;
    }
  }

  void _startPolling(String token) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
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
            final List<dynamic> customerQueues = jsonResponse['data']['customerQueues'];
            final currentQueue = customerQueues.firstWhere(
              (queue) => queue['qid'] == _queueId,
              orElse: () => null,
            );
            
            if (currentQueue != null) {
              final processedData = _processQueueData(currentQueue);
              if (mounted) {
                setState(() {
                  _queueData = processedData;
                });
              }
            }
          }
        }
      } catch (e) {
        print('Polling error: $e');
      }
    });
  }

  Map<String, dynamic> _processQueueData(Map<String, dynamic>? data) {
    if (data == null) return {};
    
    return {
      'queueName': data['queueName'],
      'currentRank': _parseInt(data['currentRank']),
      'currentQueueSize': _parseInt(data['currentQueueSize']),
      'joinedPosition': _parseInt(data['joinedPosition']),
      'comment': data['comment'],
      'inQoinCharged': _parseInt(data['inQoinCharged']),
      'processed': _parseInt(data['processed']),
      'status': data['status'],
      'message': data['message'],
      'timestamp': data['timestamp'],
    };
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value == "Infinity" || value == "infinity") return 999999;
      return int.tryParse(value) ?? 0;
    }
    return value as int;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _eventController?.close();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF181111),
                        size: 24,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Queue Status',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : _isCompleted
                          ? _buildCompletedView()
                          : _buildQueueStatusView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStatusView() {
    if (_queueData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Queue Name
          Text(
            _queueData!['queueName'] ?? 'Queue',
            style: const TextStyle(
              color: Color(0xFF181111),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Position Card
          Card(
            elevation: 0,
            color: const Color(0xFFF4F0F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Position',
                    style: TextStyle(
                      color: Color(0xFF886364),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_queueData!['currentRank']}',
                    style: const TextStyle(
                      color: Color(0xFF181111),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of ${_queueData!['currentQueueSize']} people',
                    style: const TextStyle(
                      color: Color(0xFF886364),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Queue Details
          Card(
            elevation: 0,
            color: const Color(0xFFF4F0F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Queue Details',
                    style: TextStyle(
                      color: Color(0xFF181111),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Joined Position', '${_queueData!['joinedPosition']}'),
                  if (_queueData!['comment'] != null)
                    _buildDetailRow('Comment', _queueData!['comment']),
                  if (_queueData!['inQoinCharged'] > 0)
                    _buildDetailRow('inQoin Charged', '${_queueData!['inQoinCharged']}'),
                  _buildDetailRow('Processed', '${_queueData!['processed']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _queueData?['message'] ?? 'You have been processed',
            style: const TextStyle(
              color: Color(0xFF181111),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Queue: ${_queueData?['queueName'] ?? 'Queue'}',
            style: const TextStyle(
              color: Color(0xFF886364),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9B8BA),
              foregroundColor: const Color(0xFF191010),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back to Queues'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF886364),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF181111),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}