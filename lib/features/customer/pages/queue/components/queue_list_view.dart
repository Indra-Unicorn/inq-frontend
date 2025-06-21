import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../models/customer_queue_summary.dart';
import 'queue_card.dart';

class QueueListView extends StatelessWidget {
  final List<CustomerQueue> queues;
  final bool isCurrent;
  final VoidCallback? onQueueLeft;
  final List<String> updatingQueueIds;
  final Future<void> Function()? onRefresh;

  const QueueListView({
    super.key,
    required this.queues,
    required this.isCurrent,
    this.onQueueLeft,
    this.updatingQueueIds = const [],
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (queues.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: queues.length,
        itemBuilder: (context, index) {
          final queue = queues[index];
          final isUpdating = updatingQueueIds.contains(queue.qid);

          return QueueCard(
            queue: queue,
            isCurrent: isCurrent,
            index: index,
            onQueueLeft: onQueueLeft,
            isUpdating: isUpdating,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      child: Builder(
        builder: (context) => ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrent
                            ? Icons.queue_outlined
                            : Icons.history_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isCurrent ? 'No Active Queues' : 'No Queue History',
                      style: CommonStyle.heading3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCurrent
                          ? 'You\'re not currently in any queues'
                          : 'Your completed queues will appear here',
                      style: CommonStyle.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
