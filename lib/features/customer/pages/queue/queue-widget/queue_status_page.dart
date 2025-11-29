import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/constants/app_constants.dart';
import '../../../../../shared/constants/api_endpoints.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import 'components/queue_status_header.dart';
import 'components/queue_position_card.dart';
import 'components/queue_details_card.dart';
import 'components/queue_completed_view.dart';

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
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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

      setState(() {
        _queueData =
            _processQueueData(args['queueData'] as Map<String, dynamic>?);
        _isLoading = false;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        setState(() {
          _error = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      await _trySSEConnection(token);

      if (_subscription == null) {
        _startPolling(token);
      }
    } catch (e) {
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
      _eventController = StreamController<Map<String, dynamic>>();
      final response = await http.get(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/queue-manager/$_queueId/live-position'),
        headers: {
          'Accept': 'text/event-stream',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to connect to SSE stream: ${response.statusCode}');
      }

      _subscription =
          Stream.fromIterable(response.body.split('\n')).listen((line) {
        if (line.startsWith('data: ')) {
          try {
            final jsonStr = line.substring(6);
            final data = json.decode(jsonStr);

            if (data['status'] == 'completed') {
              _eventController?.add({
                'status': 'completed',
                'message': data['message'],
                'timestamp': data['timestamp'],
              });
              _isCompleted = true;
            } else {
              final Map<String, dynamic> processedData =
                  _processQueueData(data);
              _eventController?.add(processedData);
            }
          } catch (e) {
          }
        }
      });

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
            final List<dynamic> customerQueues =
                jsonResponse['data']['customerQueues'];
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            QueueStatusHeader(
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: CommonStyle.errorTextStyle,
                          ),
                        )
                      : _isCompleted
                          ? QueueCompletedView(
                              queueName: _queueData?['queueName'] ?? 'Queue',
                              message: _queueData?['message'] ??
                                  'You have been processed',
                              onBackPressed: () => Navigator.pop(context),
                            )
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
          Text(
            _queueData!['queueName'] ?? 'Queue',
            style: CommonStyle.heading2,
          ),
          const SizedBox(height: 24),
          QueuePositionCard(
            currentRank: _queueData!['currentRank'],
            currentQueueSize: _queueData!['currentQueueSize'],
          ),
          const SizedBox(height: 24),
          QueueDetailsCard(queueData: _queueData!),
        ],
      ),
    );
  }
}
