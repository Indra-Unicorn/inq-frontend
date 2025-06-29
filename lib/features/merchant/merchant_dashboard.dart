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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MerchantDashboardController(),
      child: Consumer<MerchantDashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  DashboardHeader(
                    title: 'Queue Management',
                    onAddPressed: _showCreateQueueDialog,
                    addButtonTooltip: 'Create Queue',
                  ),

                  // Merchant Info Card
                  MerchantInfoCard(
                    name: controller.merchantName,
                    email: controller.merchantEmail,
                    inQoin: controller.merchantInQoin,
                    totalShops: controller.totalShops,
                    isLoading: controller.isLoadingMerchantData,
                  ),

                  // Stats Summary
                  if (controller.queues.isNotEmpty)
                    StatsSummaryCard(
                      totalQueues: controller.totalQueues,
                      activeQueues: controller.activeQueues,
                      totalCustomers: controller.totalCustomers,
                    ),

                  // Queue List Header
                  QueueListHeader(
                    title: 'Your Queues',
                    onRefresh: controller.loadInitialData,
                  ),

                  // Queue List
                  Expanded(
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
                      onStop: controller.stopQueue,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
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
      ),
    );
  }
}
