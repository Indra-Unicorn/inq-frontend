import 'package:flutter/material.dart';
import 'dart:async';
import 'models/merchant_queue.dart';
import 'services/merchant_queue_service.dart';
import 'components/close_queue_confirmation_dialog.dart';
import '../../shared/constants/app_colors.dart';

class QueueManagement extends StatefulWidget {
  final MerchantQueue queue;

  const QueueManagement({super.key, required this.queue});

  @override
  State<QueueManagement> createState() => _QueueManagementState();
}

class _QueueManagementState extends State<QueueManagement>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  MerchantQueue? _queueDetails;
  List<Map<String, dynamic>> _topCustomers = [];
  String? _errorMessage;
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  bool _isPollingActive = false;
  int _secondsUntilNextRefresh = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQueueDetails().then((_) {
      _startPolling();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _stopCountdown();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _startPolling();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _stopPolling();
        break;
      case AppLifecycleState.hidden:
        _stopPolling();
        break;
    }
  }

  void _startPolling() {
    if (!_isPollingActive && mounted) {
      _resetCountdown();
      _startCountdown();
      
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          _refreshQueueData();
          _resetCountdown();
        }
      });
      _isPollingActive = true;
    }
  }

  void _stopPolling() {
    if (_isPollingActive) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      _isPollingActive = false;
      _stopCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsUntilNextRefresh > 0) {
            _secondsUntilNextRefresh--;
          } else {
            _resetCountdown();
          }
        });
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _resetCountdown() {
    setState(() {
      _secondsUntilNextRefresh = 10;
    });
  }

  Future<void> _loadQueueDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final queueDetails =
          await MerchantQueueService.getQueueDetails(widget.queue.qid);
      setState(() {
        _queueDetails = queueDetails;
        _isLoading = false;
      });

      // Fetch real queue members from API
      await _loadQueueMembers();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadQueueMembers() async {
    try {
      final members =
          await MerchantQueueService.getQueueMembers(widget.queue.qid);
      setState(() {
        _topCustomers = members
            .take(3)
            .map((member) => {
                  'name': member.customerName ?? 'Unknown',
                  'reservationId': member.id,
                  'imageUrl': null, // No image in API, can use placeholder
                  'position': member.currentRank,
                  'waitTime': member.estimatedWaitTimeDisplay,
                })
            .toList();
      });
    } catch (e) {
      setState(() {
        _topCustomers = [];
      });
    }
  }

  /// Silent refresh for polling - updates queue data without loading states
  Future<void> _refreshQueueData() async {
    try {
      final queueDetails =
          await MerchantQueueService.getQueueDetails(widget.queue.qid);
      final members =
          await MerchantQueueService.getQueueMembers(widget.queue.qid);
      
      setState(() {
        _queueDetails = queueDetails;
        _topCustomers = members
            .take(3)
            .map((member) => {
                  'name': member.customerName ?? 'Unknown',
                  'reservationId': member.id,
                  'imageUrl': null,
                  'position': member.currentRank,
                  'waitTime': member.estimatedWaitTimeDisplay,
                })
            .toList();
      });
    } catch (e) {
      // Silent failure for polling - don't update error state
    }
  }

  Future<void> _processNextCustomer() async {
    try {
      await MerchantQueueService.processNextCustomer(widget.queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer processed successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      _stopPolling();
      _stopCountdown();
      await _loadQueueDetails(); // Refresh queue details
      _startPolling();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pauseQueue() async {
    try {
      await MerchantQueueService.pauseQueue(widget.queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue paused successfully'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      _stopPolling();
      _stopCountdown();
      await _loadQueueDetails(); // Refresh queue details
      _startPolling();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resumeQueue() async {
    try {
      await MerchantQueueService.resumeQueue(widget.queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue resumed successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      _stopPolling();
      _stopCountdown();
      await _loadQueueDetails(); // Refresh queue details
      _startPolling();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCloseQueueDialog() async {
    final queue = _queueDetails ?? widget.queue;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CloseQueueConfirmationDialog(
        queueName: queue.name,
        currentCustomers: queue.size,
        onConfirm: () {
          Navigator.of(context).pop();
          _stopQueue();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _stopQueue() async {
    try {
      await MerchantQueueService.stopQueue(widget.queue.qid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue closed successfully'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      _stopPolling();
      _stopCountdown();
      await _loadQueueDetails(); // Refresh queue details
      _startPolling();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final queue = _queueDetails ?? widget.queue;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1B0E0E),
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Queue Details',
                      style: TextStyle(
                        color: Color(0xFF1B0E0E),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Auto-refresh timer display
                  if (_isPollingActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_secondsUntilNextRefresh}s',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Queue Status Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF8F5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              queue.statusColor.withOpacity(0.1),
                              queue.statusColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getQueueIcon(queue),
                          color: queue.statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              queue.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B0E0E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: queue.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    queue.statusDisplay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: queue.statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  queue.timeSinceUpdate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8B5B5C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Queue Stats
                  Row(
                    children: [
                      _buildQueueStat(
                        icon: Icons.people,
                        label: 'In Queue',
                        value: queue.size.toString(),
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 20),
                      _buildQueueStat(
                        icon: Icons.check_circle,
                        label: 'Processed',
                        value: queue.processed.toString(),
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 20),
                      _buildQueueStat(
                        icon: Icons.speed,
                        label: 'Rate',
                        value: queue.processingRateDisplay,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 20),
                      _buildQueueStat(
                        icon: Icons.monetization_on,
                        label: 'InQoin',
                        value: queue.inQoinRate.toString(),
                        color: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress Bar
                  if (queue.maxSize > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: queue.capacityPercentage / 100,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCapacityColor(queue),
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${queue.size}/${queue.maxSize} (${queue.capacityPercentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getCapacityColor(queue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Top 3 Customers Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Text(
                    'Next in Line',
                    style: TextStyle(
                      color: Color(0xFF1B0E0E),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF8B5B5C)),
                    tooltip: 'Refresh',
                    onPressed: () async {
                      _stopPolling();
                      _stopCountdown();
                      await _loadQueueDetails();
                      _startPolling();
                    },
                  ),
                ],
              ),
            ),

            // Customer List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading queue details...',
                            style: TextStyle(
                              color: Color(0xFF8B5B5C),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFFF44336),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error loading queue details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B0E0E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFF8B5B5C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadQueueDetails,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _topCustomers.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Color(0xFF8B5B5C),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No customers in queue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B0E0E),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Customers will appear here when they join',
                                    style: TextStyle(
                                      color: Color(0xFF8B5B5C),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _topCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _topCustomers[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Position Badge
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4CAF50),
                                              Color(0xFF45A049)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${customer['position']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Customer Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1B0E0E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: ${customer['reservationId']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF8B5B5C),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Est. wait: ${customer['waitTime']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF4CAF50),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action Button
                                      if (customer['position'] == 1)
                                        ElevatedButton.icon(
                                          onPressed: _processNextCustomer,
                                          icon: const Icon(Icons.play_arrow,
                                              size: 18),
                                          label: const Text('Process'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4CAF50),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (queue.isActive) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _processNextCustomer,
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Process Next Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pauseQueue,
                            icon: const Icon(Icons.pause, size: 20),
                            label: const Text('Pause'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showCloseQueueDialog,
                            icon: const Icon(Icons.stop, size: 20),
                            label: const Text('Close'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF44336),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (queue.isPaused) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resumeQueue,
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Resume Queue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showCloseQueueDialog,
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('Close Queue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else if (queue.isStopped) ...[
                    // Closed/Stopped Queue - Show Resume Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF666666),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Queue is closed. You can reopen it to start accepting customers again.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _resumeQueue,
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('Reopen Queue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B5B5C),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQueueIcon(MerchantQueue queue) {
    if (queue.isActive) return Icons.play_circle_filled;
    if (queue.isPaused) return Icons.pause_circle_filled;
    if (queue.isStopped) return Icons.stop_circle;
    return Icons.queue;
  }

  Color _getCapacityColor(MerchantQueue queue) {
    if (queue.isAtCapacity) return const Color(0xFFF44336);
    if (queue.isNearCapacity) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }
}
