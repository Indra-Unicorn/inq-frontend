import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../models/customer_queue_summary.dart';
import 'current_position_widget.dart';
import 'queue_info_row.dart';
import 'leave_queue_dialog.dart';
import 'adaptive_delay_indicator.dart';
import '../services/queue_status_service.dart';
import '../services/polling_config.dart';

class QueueCard extends StatelessWidget {
  final CustomerQueue queue;
  final bool isCurrent;
  final int index;
  final VoidCallback? onQueueLeft;
  final bool isUpdating;

  const QueueCard({
    super.key,
    required this.queue,
    required this.isCurrent,
    required this.index,
    this.onQueueLeft,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundLight.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUpdating
              ? Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQueueHeader(context),
                  const SizedBox(height: 12),
                  if (isCurrent) ...[
                    CurrentPositionWidget(queue: queue),
                  ],
                  QueueInfoRow(queue: queue),
                  if (queue.comment != null && queue.comment!.isNotEmpty)
                    _buildCommentRow(),
                ],
              ),
            ),
            if (isUpdating)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCurrent
                  ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                  : [AppColors.success, AppColors.success.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCurrent ? Icons.queue : Icons.check_circle,
            color: AppColors.textWhite,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      queue.queueName ?? 'Unknown Queue',
                      style: CommonStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrent &&
                      PollingConfig.strategy ==
                          PollingStrategy.adaptivePolling) ...[
                    const SizedBox(width: 8),
                    AdaptiveDelayIndicator(
                      currentPosition: queue.currentRank ?? 0,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCurrent ? 'Active' : 'Completed',
                  style: CommonStyle.caption.copyWith(
                    color: isCurrent ? AppColors.primary : AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Leave button for current queues
        if (isCurrent)
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => _showLeaveDialog(context),
              icon: Icon(
                Icons.exit_to_app,
                size: 18,
                color: AppColors.error,
              ),
              tooltip: 'Leave Queue',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showLeaveDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LeaveQueueDialog(
        queueName: queue.queueName ?? 'Unknown Queue',
        onConfirm: _handleLeaveQueue,
      ),
    );

    if (result == true && onQueueLeft != null) {
      onQueueLeft!();
    }
  }

  Future<void> _handleLeaveQueue(String reason) async {
    try {
      await QueueStatusService.leaveQueue(queue.qid, reason);
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildCommentRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.comment,
              size: 14,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment',
                  style: CommonStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  queue.comment!,
                  style: CommonStyle.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
