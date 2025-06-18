import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/queue_service.dart';
import '../../models/customer_queue_summary.dart';

class CustomerQueuesPage extends StatefulWidget {
  const CustomerQueuesPage({super.key});

  @override
  State<CustomerQueuesPage> createState() => _CustomerQueuesPageState();
}

class _CustomerQueuesPageState extends State<CustomerQueuesPage> {
  final QueueService _queueService = QueueService();
  CustomerQueueSummary? _queueSummary;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchQueueSummary();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _startPolling();
      _isInitialized = true;
    }
  }

  Future<void> _fetchQueueSummary() async {
    try {
      final summary = await _queueService.getCustomerQueueSummary();
      if (mounted) {
        setState(() {
          _queueSummary = summary;
          _isLoading = false;
        });
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

  void _startPolling() {
    // Poll every 5 seconds to get updated queue information
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchQueueSummary();
      }
    });
  }

  Future<void> _refreshQueues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchQueueSummary();
  }

  @override
  void dispose() {
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
                      'My Queues',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: _refreshQueues,
                    child: Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.refresh,
                        color: Color(0xFF181111),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Queues Section
            if (_queueSummary?.customerQueues.isNotEmpty ?? false) ...[
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Active Queues',
                  style: TextStyle(
                    color: Color(0xFF181111),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.015,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _queueSummary!.customerQueues.length,
                  itemBuilder: (context, index) {
                    final queue = _queueSummary!.customerQueues[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        elevation: 0,
                        color: const Color(0xFFF4F0F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            queue.queueName ?? 'Queue ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF181111),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Current Position: ${queue.currentRank}',
                                style: const TextStyle(
                                  color: Color(0xFF886364),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Queue Size: ${queue.currentQueueSize}',
                                style: const TextStyle(
                                  color: Color(0xFF886364),
                                  fontSize: 14,
                                ),
                              ),
                              if (queue.comment != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Comment: ${queue.comment}',
                                  style: const TextStyle(
                                    color: Color(0xFF886364),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              if (queue.inQoinCharged > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'inQoin Charged: ${queue.inQoinCharged}',
                                  style: const TextStyle(
                                    color: Color(0xFF886364),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              final queueData = {
                                'queueName': queue.queueName,
                                'currentRank': queue.currentRank,
                                'currentQueueSize': queue.currentQueueSize,
                                'joinedPosition': queue.joinedPosition,
                                'comment': queue.comment,
                                'inQoinCharged': queue.inQoinCharged,
                                'processed': queue.processed,
                              };
                              
                              Navigator.pushNamed(
                                context,
                                '/queue-status',
                                arguments: {
                                  'queueId': queue.qid,
                                  'queueData': queueData,
                                },
                              ).then((_) {
                                // Refresh the queue list when returning from queue status page
                                _fetchQueueSummary();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE9B8BA),
                              foregroundColor: const Color(0xFF191010),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('View Status'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Past Queues Section
            if (_queueSummary?.customerPastQueues.isNotEmpty ?? false) ...[
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Past Queues',
                  style: TextStyle(
                    color: Color(0xFF181111),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.015,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _queueSummary!.customerPastQueues.length,
                  itemBuilder: (context, index) {
                    final queue = _queueSummary!.customerPastQueues[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        elevation: 0,
                        color: const Color(0xFFF4F0F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            queue.queueName ?? 'Queue ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF181111),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Processed: ${queue.processed}',
                                style: const TextStyle(
                                  color: Color(0xFF886364),
                                  fontSize: 14,
                                ),
                              ),
                              if (queue.comment != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Comment: ${queue.comment}',
                                  style: const TextStyle(
                                    color: Color(0xFF886364),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              if (queue.inQoinCharged > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'inQoin Charged: ${queue.inQoinCharged}',
                                  style: const TextStyle(
                                    color: Color(0xFF886364),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Empty State
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshQueues,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9B8BA),
                          foregroundColor: const Color(0xFF191010),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if ((_queueSummary?.customerQueues.isEmpty ?? true) &&
                (_queueSummary?.customerPastQueues.isEmpty ?? true))
              const Expanded(
                child: Center(
                  child: Text(
                    'No queues found',
                    style: TextStyle(
                      color: Color(0xFF886364),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}