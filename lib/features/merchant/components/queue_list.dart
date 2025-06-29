import 'package:flutter/material.dart';
import '../models/merchant_queue.dart';
import 'queue_card.dart';
import 'loading_error_states.dart';
import '../../../shared/constants/app_colors.dart';

class QueueList extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<MerchantQueue> queues;
  final VoidCallback onRefresh;
  final VoidCallback? onCreateQueue;
  final Function(MerchantQueue) onQueueTap;
  final Function(MerchantQueue) onProcessNext;
  final Function(MerchantQueue) onPause;
  final Function(MerchantQueue) onResume;
  final Function(MerchantQueue) onStop;

  const QueueList({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.queues,
    required this.onRefresh,
    this.onCreateQueue,
    required this.onQueueTap,
    required this.onProcessNext,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingState();
    }

    if (errorMessage != null) {
      return ErrorState(
        message: errorMessage!,
        onRetry: onRefresh,
      );
    }

    if (queues.isEmpty) {
      return EmptyState(
        onActionPressed: onCreateQueue,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: queues.length,
        itemBuilder: (context, index) {
          final queue = queues[index];
          return QueueCard(
            queue: queue,
            onTap: () => onQueueTap(queue),
            onProcessNext: () => onProcessNext(queue),
            onPause: () => onPause(queue),
            onResume: () => onResume(queue),
            onStop: () => onStop(queue),
          );
        },
      ),
    );
  }
}
