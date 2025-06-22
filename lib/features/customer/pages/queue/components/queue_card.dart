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
      margin: EdgeInsets.only(bottom: 16, top: widget.index == 0 ? 0 : 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundLight.withOpacity(0.95),
            ],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
          border: widget.isUpdating
              ? Border.all(
                  color: AppColors.success.withOpacity(0.4),
                  width: 1.5,
                )
              : Border.all(
                  color: AppColors.backgroundLight.withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQueueHeader(context),
                  const SizedBox(height: 16),
                  if (widget.isCurrent) ...[
                    CurrentPositionWidget(queue: widget.queue),
                    const SizedBox(height: 16),
                  ],
                  QueueInfoRow(queue: widget.queue),
                  if (widget.queue.comment != null &&
                      widget.queue.comment!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCommentRow(),
                  ],
                ],
              ),
            ),
            if (widget.isUpdating)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isCurrent
                  ? [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ]
                  : [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
              stops: const [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.isCurrent ? AppColors.primary : AppColors.success)
                        .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.isCurrent ? Icons.queue : Icons.check_circle,
            color: AppColors.textWhite,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isCurrent &&
                      PollingConfig.strategy ==
                          PollingStrategy.adaptivePolling) ...[
                    const SizedBox(width: 10),
                    AdaptiveDelayIndicator(
                      currentPosition: widget.queue.currentRank ?? 0,
                    ),
                  ],
                  if (widget.isCurrent && widget.lastUpdateTime != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _getTimeText(),
                            style: CommonStyle.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.isCurrent
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.isCurrent
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.success.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.isCurrent ? 'Active' : 'Completed',
                  style: CommonStyle.caption.copyWith(
                    color: widget.isCurrent
                        ? AppColors.primary
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Leave button for current queues
        if (widget.isCurrent)
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.error.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => _showLeaveDialog(context),
              icon: Icon(
                Icons.exit_to_app,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: 'Leave Queue',
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.06),
            AppColors.warning.withOpacity(0.03),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.comment,
              size: 16,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment',
                  style: CommonStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.queue.comment!,
                  style: CommonStyle.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
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
