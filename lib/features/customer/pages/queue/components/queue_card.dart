import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../models/customer_queue_summary.dart';
import 'current_position_widget.dart';
import 'queue_info_row.dart';
import 'leave_queue_dialog.dart';
import 'adaptive_delay_indicator.dart';
import '../services/queue_status_service.dart';
import '../services/polling_config.dart';

class QueueCard extends StatefulWidget {
  final CustomerQueue queue;
  final bool isCurrent;
  final int index;
  final VoidCallback? onQueueLeft;
  final bool isUpdating;
  final DateTime? lastUpdateTime;

  const QueueCard({
    super.key,
    required this.queue,
    required this.isCurrent,
    required this.index,
    this.onQueueLeft,
    this.isUpdating = false,
    this.lastUpdateTime,
  });

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(QueueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastUpdateTime != widget.lastUpdateTime) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.lastUpdateTime != null && widget.isCurrent) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            // Trigger rebuild to update the time display
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getTimeText() {
    if (widget.lastUpdateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(widget.lastUpdateTime!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 12, top: widget.index == 0 ? 0 : 4),
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
          border: widget.isUpdating
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
                  if (widget.isCurrent) ...[
                    CurrentPositionWidget(queue: widget.queue),
                  ],
                  QueueInfoRow(queue: widget.queue),
                  if (widget.queue.comment != null &&
                      widget.queue.comment!.isNotEmpty)
                    _buildCommentRow(),
                ],
              ),
            ),
            if (widget.isUpdating)
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
              colors: widget.isCurrent
                  ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                  : [AppColors.success, AppColors.success.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.isCurrent ? Icons.queue : Icons.check_circle,
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
                      widget.queue.queueName ?? 'Unknown Queue',
                      style: CommonStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isCurrent &&
                      PollingConfig.strategy ==
                          PollingStrategy.adaptivePolling) ...[
                    const SizedBox(width: 8),
                    AdaptiveDelayIndicator(
                      currentPosition: widget.queue.currentRank ?? 0,
                    ),
                  ],
                  if (widget.isCurrent && widget.lastUpdateTime != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 10,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _getTimeText(),
                            style: CommonStyle.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
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
                  color: widget.isCurrent
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isCurrent ? 'Active' : 'Completed',
                  style: CommonStyle.caption.copyWith(
                    color: widget.isCurrent
                        ? AppColors.primary
                        : AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Leave button for current queues
        if (widget.isCurrent)
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
        queueName: widget.queue.queueName ?? 'Unknown Queue',
        onConfirm: _handleLeaveQueue,
      ),
    );

    if (result == true && widget.onQueueLeft != null) {
      widget.onQueueLeft!();
    }
  }

  Future<void> _handleLeaveQueue(String reason) async {
    try {
      await QueueStatusService.leaveQueue(widget.queue.qid, reason);
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
                  widget.queue.comment!,
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
