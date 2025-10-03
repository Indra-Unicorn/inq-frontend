import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/merchant_dashboard_controller.dart';
import 'models/merchant_queue.dart';
import 'components/dashboard_header.dart';
import 'components/merchant_info_card.dart';
import 'components/stats_summary_card.dart';
import 'components/queue_list_header.dart';
import 'components/queue_list.dart';
import 'components/merchant_bottom_navigation.dart';
import 'components/create_queue_dialog.dart';
import 'components/close_queue_confirmation_dialog.dart';
import '../../../shared/constants/app_colors.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the controller when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantDashboardController>().loadInitialData();
    });
  }

  Future<void> _showCreateQueueDialog() async {
    final controller = context.read<MerchantDashboardController>();

    await showDialog(
      context: context,
      builder: (context) => CreateQueueDialog(
        onCreateQueue: controller.createQueue,
      ),
    );
  }

  void _navigateToQueueDetails(MerchantQueue queue) {
    Navigator.pushNamed(
      context,
      '/queue-management',
      arguments: queue,
    );
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/merchant-profile');
  }

  Future<void> _showCloseQueueDialog(MerchantQueue queue) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CloseQueueConfirmationDialog(
        queueName: queue.name,
        currentCustomers: queue.size,
        onConfirm: () {
          Navigator.of(context).pop();
          _closeQueue(queue);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _closeQueue(MerchantQueue queue) async {
    final controller = context.read<MerchantDashboardController>();
    try {
      await controller.stopQueue(queue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Queue closed successfully'),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<MerchantDashboardController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Merchant Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline,
                    color: AppColors.textSecondary),
                tooltip: 'Profile',
                onPressed: _navigateToProfile,
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Merchant Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: MerchantInfoCard(
                      name: controller.merchantName,
                      email: controller.merchantEmail,
                      inQoin: controller.merchantInQoin,
                      totalShops: controller.totalShops,
                      isLoading: controller.isLoadingMerchantData,
                    ),
                  ),
                  // Stats Summary
                  if (controller.queues.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: StatsSummaryCard(
                        totalQueues: controller.totalQueues,
                        activeQueues: controller.activeQueues,
                        totalCustomers: controller.totalCustomers,
                      ),
                    ),
                  // Queue List Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Your Queues',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: AppColors.textSecondary),
                          tooltip: 'Refresh',
                          onPressed: controller.loadInitialData,
                        ),
                      ],
                    ),
                  ),
                  // Queue List
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: QueueList(
                        isLoading: controller.isLoading,
                        errorMessage: controller.errorMessage,
                        queues: controller.queues,
                        onRefresh: controller.loadInitialData,
                        onCreateQueue: _showCreateQueueDialog,
                        onQueueTap: _navigateToQueueDetails,
                        onProcessNext: controller.processNextCustomer,
                        onPause: controller.pauseQueue,
                        onResume: controller.resumeQueue,
                        onStop: _showCloseQueueDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateQueueDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, size: 28),
            tooltip: 'Create Queue',
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: MerchantBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            onProfileTap: _navigateToProfile,
          ),
        );
      },
    );
  }
}
