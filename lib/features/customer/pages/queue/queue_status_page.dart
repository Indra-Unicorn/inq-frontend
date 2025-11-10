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
    print('🚀🚀🚀 QUEUE STATUS PAGE INITIALIZED - WITH COMPLETION DIALOG FEATURE 🚀🚀🚀');
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _initializePollingManager();
    _fetchQueueData();
  }

  void _initializePollingManager() {
    print('🔧 Initializing polling manager');
    _pollingManager = PositionPollingManager(
      onPositionUpdate: _handlePositionUpdate,
      onError: _handlePollingError,
    );
    print('🔧 Polling manager initialized');
  }

  void _handlePositionUpdate(CustomerQueue updatedQueue) {
    print('🔄 _handlePositionUpdate called for queue: ${updatedQueue.qid}');
    print('🔄 Updated queue data: rank=${updatedQueue.currentRank}, waitTime=${updatedQueue.estimatedWaitTime}');
    
    setState(() {
      // Update the queue in the current queues list
      final index = _currentQueues.indexWhere((q) => q.qid == updatedQueue.qid);
      print('🔄 Queue index in current list: $index');
      
      if (index != -1) {
        final previousQueue = _currentQueues[index];
        print('🔄 Previous queue data: rank=${previousQueue.currentRank}, waitTime=${previousQueue.estimatedWaitTime}');
        _currentQueues[index] = updatedQueue;
        
        // Check if queue is completed (position became 0 or ready)
        _checkQueueCompletion(previousQueue, updatedQueue);
      } else {
        print('❌ Queue not found in current queues list!');
      }
    });
  }

  void _checkQueueCompletion(CustomerQueue previousQueue, CustomerQueue updatedQueue) {
    // Check if the queue just became ready - ONLY when currentRank becomes 0
    // We should not rely on estimatedWaitTime alone as it can be 0 even at rank 1
    final wasAtPositionZero = previousQueue.currentRank == 0;
    final isNowAtPositionZero = updatedQueue.currentRank == 0;
    
    print('Queue completion check for ${updatedQueue.qid}:');
    print('  Previous: rank=${previousQueue.currentRank}, waitTime=${previousQueue.estimatedWaitTime}');
    print('  Current: rank=${updatedQueue.currentRank}, waitTime=${updatedQueue.estimatedWaitTime}');
    print('  wasAtPositionZero=$wasAtPositionZero, isNowAtPositionZero=$isNowAtPositionZero');
    print('  alreadyCompleted=${_completedQueueIds.contains(updatedQueue.qid)}');
    
    // Only trigger when rank transitions from non-zero to zero
    if (!wasAtPositionZero && isNowAtPositionZero && !_completedQueueIds.contains(updatedQueue.qid)) {
      print('🎉 Queue completed! Showing dialog...');
      _completedQueueIds.add(updatedQueue.qid);
      _showQueueCompletionDialog(updatedQueue);
    } else {
      print('❌ Not showing dialog - conditions not met');
      print('   - Was at position 0: $wasAtPositionZero');
      print('   - Is now at position 0: $isNowAtPositionZero'); 
      print('   - Already completed: ${_completedQueueIds.contains(updatedQueue.qid)}');
    }
  }

  void _handlePollingError(String queueId, String error) {
    // Log error but don't show to user unless it's critical
    print('Polling error for queue $queueId: $error');

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
    print('🚀 _startPolling called. isPollingActive=$_isPollingActive, currentQueues.length=${_currentQueues.length}');
    if (!_isPollingActive && _currentQueues.isNotEmpty) {
      print('🚀 Starting polling for ${_currentQueues.length} queues');
      _pollingManager.startPolling(_currentQueues);
      _isPollingActive = true;
      print('🚀 Polling started successfully');
    } else {
      print('🚀 Polling not started - already active or no queues');
    }
  }

  void _stopPolling() {
    print('🛑 _stopPolling called. isPollingActive=$_isPollingActive');
    if (_isPollingActive) {
      print('🛑 Stopping all polling');
      _pollingManager.stopAllPolling();
      _isPollingActive = false;
      print('🛑 Polling stopped successfully');
    } else {
      print('🛑 Polling not stopped - already inactive');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _pollingManager.dispose();
    // Clear completed queue IDs when page is disposed
    _completedQueueIds.clear();
    print('🧹 Cleared completed queue IDs on dispose');
    super.dispose();
  }

  Future<void> _fetchQueueData() async {
    print('📥 _fetchQueueData called');
    try {
      final customerQueueSummary = await QueueStatusService.fetchQueueData();
      print('📥 Received queue data: ${customerQueueSummary.customerQueues.length} current, ${customerQueueSummary.customerPastQueues.length} past');

      setState(() {
        _currentQueues = customerQueueSummary.customerQueues;
        _pastQueues = customerQueueSummary.customerPastQueues;
        _isLoading = false;
        
        // Clear completed queue IDs for queues that are no longer in current list
        final currentQueueIds = _currentQueues.map((q) => q.qid).toSet();
        _completedQueueIds.removeWhere((qid) => !currentQueueIds.contains(qid));
        
        print('📥 Current queues after update:');
        for (final queue in _currentQueues) {
          print('  - ${queue.qid}: rank=${queue.currentRank}, waitTime=${queue.estimatedWaitTime}');
        }
        print('📥 Completed queue IDs: $_completedQueueIds');
      });

      // Check for queues that are already ready on initial load
      _checkInitialReadyQueues();

      // Start polling after data is loaded
      _startPolling();
    } catch (e) {
      print('❌ Error fetching queue data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _checkInitialReadyQueues() {
    print('🔍 Checking initial ready queues. Current queues: ${_currentQueues.length}');
    print('🔍 Completed queue IDs: $_completedQueueIds');
    
    for (final queue in _currentQueues) {
      // Only consider a queue ready if currentRank is actually 0
      final isReady = queue.currentRank == 0;
      print('Initial check for queue ${queue.qid}: rank=${queue.currentRank}, waitTime=${queue.estimatedWaitTime}, isReady=$isReady');
      print('Already completed: ${_completedQueueIds.contains(queue.qid)}');
      
      if (isReady && !_completedQueueIds.contains(queue.qid)) {
        print('🎉 Queue ${queue.qid} is already ready on initial load!');
        _completedQueueIds.add(queue.qid);
        // Delay showing dialog to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            print('🎉 Showing dialog for initially ready queue: ${queue.qid}');
            _showQueueCompletionDialog(queue);
          }
        });
      } else {
        print('❌ Not showing dialog for ${queue.qid} - isReady: $isReady, alreadyCompleted: ${_completedQueueIds.contains(queue.qid)}');
      }
    }
  }

  Future<void> _showQueueCompletionDialog(CustomerQueue completedQueue) async {
    print('📱 _showQueueCompletionDialog called for queue: ${completedQueue.qid}');
    print('📱 Widget mounted: $mounted');
    
    if (!mounted) {
      print('❌ Widget not mounted, returning');
      return;
    }

    print('📱 Showing completion dialog...');
    try {
      await QueueCompletionDialog.show(
        context,
        completedQueue: completedQueue,
        onViewHistory: () {
          print('📱 User clicked View History');
          Navigator.of(context).pop(); // Close dialog
          _moveQueueToHistoryAndSwitch(completedQueue);
        },
        onDismiss: () {
          print('📱 User clicked Dismiss');
          Navigator.of(context).pop(); // Close dialog
          _moveQueueToHistory(completedQueue);
        },
      );
      print('📱 Dialog completed');
    } catch (e) {
      print('❌ Error showing dialog: $e');
    }
  }

  Future<void> _moveQueueToHistory(CustomerQueue completedQueue) async {
    // Refresh data to get updated queue lists from server
    await _fetchQueueData();
  }

  Future<void> _moveQueueToHistoryAndSwitch(CustomerQueue completedQueue) async {
    // Refresh data first
    await _fetchQueueData();
    
    // Switch to history tab if not already there
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
      // Add a test button for debugging
      floatingActionButton: _currentQueues.isNotEmpty ? FloatingActionButton(
        onPressed: () {
          print('🧪 Test button pressed - showing completion dialog');
          _showQueueCompletionDialog(_currentQueues.first);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.bug_report),
        tooltip: 'Test Completion Dialog',
      ) : null,
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
