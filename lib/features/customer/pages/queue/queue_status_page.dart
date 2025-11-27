import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/customer_queue_summary.dart';
import 'components/queue_status_header.dart';
import 'components/queue_list_view.dart';
import 'components/loading_error_states.dart';
import 'components/queue_completion_dialog.dart';
import 'services/queue_status_service.dart';
import 'services/position_polling_manager.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<CustomerQueue> _currentQueues = [];
  List<CustomerPastQueue> _pastQueues = [];
  bool _isLoading = true;
  String? _error;
  late PositionPollingManager _pollingManager;
  bool _isPollingActive = false;
  Set<String> _completedQueueIds = {}; // Track queues that have been completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _initializePollingManager();
    _fetchQueueData();
  }

  void _initializePollingManager() {
    _pollingManager = PositionPollingManager(
      onPositionUpdate: _handlePositionUpdate,
      onError: _handlePollingError,
    );
  }

  void _handlePositionUpdate(CustomerQueue updatedQueue) {
    setState(() {
      // Update the queue in the current queues list
      final index = _currentQueues.indexWhere((q) => q.qid == updatedQueue.qid);
      
      if (index != -1) {
        final previousQueue = _currentQueues[index];
        _currentQueues[index] = updatedQueue;
        
        // Check if queue is completed (position became 0 or ready)
        _checkQueueCompletion(previousQueue, updatedQueue);
      }
    });
  }

  void _checkQueueCompletion(CustomerQueue previousQueue, CustomerQueue updatedQueue) {
    // Check if the queue just became ready - ONLY when currentRank becomes 0
    // We should not rely on estimatedWaitTime alone as it can be 0 even at rank 1
    final wasAtPositionZero = previousQueue.currentRank == 0;
    final isNowAtPositionZero = updatedQueue.currentRank == 0;
    
    // Only trigger when rank transitions from non-zero to zero
    if (!wasAtPositionZero && isNowAtPositionZero && !_completedQueueIds.contains(updatedQueue.qid)) {
      _completedQueueIds.add(updatedQueue.qid);
      _showQueueCompletionDialog(updatedQueue);
    }
  }

  void _handlePollingError(String queueId, String error) {
    // Optionally show a subtle error indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position update temporarily unavailable',
            style: TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startPolling() {
    if (!_isPollingActive && _currentQueues.isNotEmpty) {
      _pollingManager.startPolling(_currentQueues);
      _isPollingActive = true;
    }
  }

  void _stopPolling() {
    if (_isPollingActive) {
      _pollingManager.stopAllPolling();
      _isPollingActive = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _pollingManager.dispose();
    // Clear completed queue IDs when page is disposed
    _completedQueueIds.clear();
    super.dispose();
  }

  Future<void> _fetchQueueData() async {
    try {
      final customerQueueSummary = await QueueStatusService.fetchQueueData();

      setState(() {
        _currentQueues = customerQueueSummary.customerQueues;
        _pastQueues = customerQueueSummary.customerPastQueues;
        _isLoading = false;
        
        // Clear completed queue IDs for queues that are no longer in current list
        final currentQueueIds = _currentQueues.map((q) => q.qid).toSet();
        _completedQueueIds.removeWhere((qid) => !currentQueueIds.contains(qid));
      });

      // Check for queues that are already ready on initial load
      _checkInitialReadyQueues();

      // Start polling after data is loaded
      _startPolling();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _checkInitialReadyQueues() {
    for (final queue in _currentQueues) {
      // Only consider a queue ready if currentRank is actually 0
      final isReady = queue.currentRank == 0;
      
      if (isReady && !_completedQueueIds.contains(queue.qid)) {
        _completedQueueIds.add(queue.qid);
        // Delay showing dialog to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showQueueCompletionDialog(queue);
          }
        });
      }
    }
  }

  Future<void> _showQueueCompletionDialog(CustomerQueue completedQueue) async {
    if (!mounted) {
      return;
    }

    try {
      await QueueCompletionDialog.show(
        context,
        completedQueue: completedQueue,
        onViewHistory: () {
          Navigator.of(context).pop(); // Close dialog
          _moveQueueToHistoryAndSwitch(completedQueue);
        },
        onDismiss: () {
          Navigator.of(context).pop(); // Close dialog
          _moveQueueToHistory(completedQueue);
        },
      );
    } catch (e) {
      // Handle dialog error silently
    }
  }

  Future<void> _moveQueueToHistory(CustomerQueue completedQueue) async {
    // Refresh data to get updated queue lists from server
    await _fetchQueueData();
  }

  Future<void> _moveQueueToHistoryAndSwitch(CustomerQueue completedQueue) async {
    // Refresh data first
    await _fetchQueueData();
    
    // Switch to  tab if not already there
    if (mounted && _tabController.index != 1) {
      _tabController.animateTo(1);
    }
  }

  Future<void> _handleQueueLeft() async {
    // Stop polling before leaving queue
    _stopPolling();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully left the queue',
            style: TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Refresh data
    await _fetchQueueData();

    // Switch to history tab
    if (mounted) {
      _tabController.animateTo(1); // Switch to history tab
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: QueueStatusHeader(
        tabController: _tabController,
        isPollingActive: _isPollingActive,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingErrorStates.buildLoadingState();
    }

    if (_error != null) {
      return LoadingErrorStates.buildErrorState(_error!, _fetchQueueData);
    }

    final updatingQueueIds = _pollingManager.getPollingQueueIds();
    final lastUpdateTimes = _pollingManager.getAllLastUpdateTimes();

    return TabBarView(
      controller: _tabController,
      children: [
        QueueListView(
          queues: _currentQueues,
          isCurrent: true,
          onQueueLeft: _handleQueueLeft,
          updatingQueueIds: updatingQueueIds,
          onRefresh: _fetchQueueData,
          lastUpdateTimes: lastUpdateTimes,
        ),
        QueueListView(
          queues: _pastQueues,
          isCurrent: false,
          onQueueLeft: _handleQueueLeft,
          updatingQueueIds: updatingQueueIds,
          onRefresh: _fetchQueueData,
          lastUpdateTimes: lastUpdateTimes,
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause polling when app is not visible
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      // Resume polling when app becomes visible again
      _startPolling();
    }
  }
}
