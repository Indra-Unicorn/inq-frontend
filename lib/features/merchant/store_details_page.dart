import 'package:flutter/material.dart';
import '../customer/models/queue.dart';
import '../customer/services/queue_service.dart';
import '../customer/models/customer_queue_summary.dart';

class StoreDetailsPage extends StatefulWidget {
  final String storeName;
  final String storeAddress;
  final String storeImage;

  const StoreDetailsPage({
    super.key,
    required this.storeName,
    required this.storeAddress,
    required this.storeImage,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final QueueService _queueService = QueueService();
  List<Queue> _queues = [];
  bool _isLoading = true;
  String? _error;
  CustomerQueueSummary? _customerQueueSummary;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    print('StoreDetailsPage initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      print('StoreDetailsPage didChangeDependencies');
      _fetchQueues();
      _fetchCustomerQueueSummary();
      _isInitialized = true;
    }
  }

  Future<void> _fetchQueues() async {
    try {
      print('Fetching queues...');
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('Route args: $args');

      if (args == null) {
        print('Args is null');
        setState(() {
          _error = 'Invalid arguments';
          _isLoading = false;
        });
        return;
      }

      final shopId = args['shopId'] as String?;
      print('Shop ID: $shopId');

      if (shopId == null) {
        print('Shop ID is null');
        setState(() {
          _error = 'Shop ID not found';
          _isLoading = false;
        });
        return;
      }

      final queues = await _queueService.getShopQueuesOnly(shopId);
      print('Fetched queues: ${queues.length}');
      if (mounted) {
        setState(() {
          _queues = queues;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _fetchQueues: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCustomerQueueSummary() async {
    try {
      print('Fetching customer queue summary...');
      final summary = await _queueService.getCustomerQueueSummary();
      print(
          'Customer queue summary: ${summary.customerQueues.length} active queues');
      if (mounted) {
        setState(() {
          _customerQueueSummary = summary;
        });
      }
    } catch (e) {
      print('Error fetching customer queue summary: $e');
    }
  }

  Future<void> _refreshData() async {
    await _fetchCustomerQueueSummary();
  }

  bool _isUserInQueue(String queueId) {
    if (_customerQueueSummary == null) return false;
    return _customerQueueSummary!.customerQueues
        .any((queue) => queue.qid == queueId);
  }

  Future<void> _showJoinQueueDialog(Queue queue) async {
    final TextEditingController commentController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Join Queue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Would you like to add a comment? (Optional)'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your comment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        final result = await _queueService.joinQueue(
                          queue.qid,
                          comment: commentController.text.trim().isEmpty
                              ? null
                              : commentController.text.trim(),
                        );
                        if (mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushNamed(
                            context,
                            '/queue-status',
                            arguments: {
                              'queueId': queue.qid,
                              'queueName': queue.name,
                              'shopName': widget.storeName,
                              'queueData': result,
                            },
                          ).then((_) {
                            // Refresh customer queue summary when returning from queue status
                            _refreshData();
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9B8BA),
                foregroundColor: const Color(0xFF191010),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF191010)),
                      ),
                    )
                  : const Text('Join Queue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
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
                  Expanded(
                    child: Text(
                      widget.storeName,
                      style: const TextStyle(
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
                    onTap: _refreshData,
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

            // Store Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.storeImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Store Address
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF886364),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.storeAddress,
                      style: const TextStyle(
                        color: Color(0xFF886364),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Queues Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Available Queues',
                style: TextStyle(
                  color: Color(0xFF181111),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),

            // Queue List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)))
                      : _queues.isEmpty
                          ? const Center(child: Text('No queues available'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _queues.length,
                              itemBuilder: (context, index) {
                                final queue = _queues[index];
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
                                        queue.name,
                                        style: const TextStyle(
                                          color: Color(0xFF181111),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'Status: ${queue.status}',
                                            style: TextStyle(
                                              color: queue.status == 'ACTIVE'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Queue Size: ${queue.size}/${queue.maxSize}',
                                            style: const TextStyle(
                                              color: Color(0xFF886364),
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (queue.inQoinRate > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'inQoin Rate: ${queue.inQoinRate}',
                                              style: const TextStyle(
                                                color: Color(0xFF886364),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: _isUserInQueue(queue.qid)
                                          ? const Text(
                                              'Already in Queue',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: queue.full
                                                  ? null
                                                  : () {
                                                      _showJoinQueueDialog(
                                                          queue);
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFE9B8BA),
                                                foregroundColor:
                                                    const Color(0xFF191010),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(queue.full
                                                  ? 'Full'
                                                  : 'Join Queue'),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
