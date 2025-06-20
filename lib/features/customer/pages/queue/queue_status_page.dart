import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/customer_queue_summary.dart';
import 'components/queue_status_header.dart';
import 'components/queue_list_view.dart';
import 'components/loading_error_states.dart';
import 'services/queue_status_service.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CustomerQueue> _currentQueues = [];
  List<CustomerQueue> _pastQueues = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchQueueData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQueueLeft() async {
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
      appBar: QueueStatusHeader(tabController: _tabController),
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

    return TabBarView(
      controller: _tabController,
      children: [
        QueueListView(
          queues: _currentQueues,
          isCurrent: true,
          onQueueLeft: _handleQueueLeft,
        ),
        QueueListView(
          queues: _pastQueues,
          isCurrent: false,
          onQueueLeft: _handleQueueLeft,
        ),
      ],
    );
  }
}
