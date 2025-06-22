import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/customer_queue_summary.dart';
import 'components/queue_status_header.dart';
import 'components/queue_list_view.dart';
import 'components/loading_error_states.dart';
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
        _currentQueues[index] = updatedQueue;
      }
    });
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
    super.dispose();
  }

  Future<void> _fetchQueueData() async {
    try {
      final customerQueueSummary = await QueueStatusService.fetchQueueData();

      setState(() {
        _currentQueues = customerQueueSummary.customerQueues;
        _pastQueues = customerQueueSummary.customerPastQueues;
        _isLoading = false;
      });

      // Start polling after data is loaded
      _startPolling();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
