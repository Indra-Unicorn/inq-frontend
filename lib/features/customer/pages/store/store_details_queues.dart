import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../../models/queue.dart';
import '../../models/queue_status.dart';
import '../../services/queue_service.dart';
import '../../../../services/auth_service.dart';

class StoreQueueCard extends StatelessWidget {
  final Queue queue;
  final VoidCallback? onJoin;
  final bool isJoining;
  final bool isUserInQueue;

  const StoreQueueCard({
    required this.queue,
    this.onJoin,
    this.isJoining = false,
    this.isUserInQueue = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        queue.name,
                        style: CommonStyle.heading3.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(queue.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(queue.status).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(queue.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(queue.status),
                            style: CommonStyle.caption.copyWith(
                              color: _getStatusColor(queue.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildDetailColumn('Queue Size', '${queue.size}/${queue.maxSize}')),
                    Container(width: 1, height: 30, color: AppColors.border.withValues(alpha: 0.3)),
                    Expanded(child: _buildDetailColumn('Processing', '${queue.processingRate}/min')),
                    Container(width: 1, height: 30, color: AppColors.border.withValues(alpha: 0.3)),
                    Expanded(child: _buildDetailColumn('inQoin Rate', '${queue.inQoinRate}')),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.border.withValues(alpha: 0.3),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          
          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (queue.status == QueueStatus.active &&
                        onJoin != null &&
                        !isJoining &&
                        !isUserInQueue)
                    ? onJoin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUserInQueue
                      ? AppColors.textTertiary
                      : (queue.status == QueueStatus.active
                          ? AppColors.primary
                          : AppColors.textTertiary),
                  foregroundColor: AppColors.textWhite,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textSecondary,
                ),
                child: isJoining
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isUserInQueue
                            ? 'Already in Queue'
                            : (queue.status == QueueStatus.active
                                ? 'Join Queue'
                                : 'Queue ${_getStatusText(queue.status).toLowerCase()}'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: CommonStyle.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: CommonStyle.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }



  String _getStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.active:
        return 'Active';
      case QueueStatus.paused:
        return 'Paused';
      case QueueStatus.closed:
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.active:
        return AppColors.queueActive;
      case QueueStatus.paused:
        return AppColors.queuePaused;
      case QueueStatus.closed:
        return AppColors.queueClosed;
      default:
        return AppColors.textSecondary;
    }
  }
}

class StoreDetailsQueues extends StatefulWidget {
  final List<Queue> queues;
  final Set<String> userCurrentQueueIds;
  final String? shopId;

  const StoreDetailsQueues({
    super.key,
    required this.queues,
    this.userCurrentQueueIds = const {},
    this.shopId,
  });

  @override
  State<StoreDetailsQueues> createState() => _StoreDetailsQueuesState();
}

class _StoreDetailsQueuesState extends State<StoreDetailsQueues> {
  final QueueService _queueService = QueueService();
  bool _isJoining = false;

  Future<void> _joinQueue(Queue queue) async {
    // Check if user is logged in before joining queue
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      final returnTo = widget.shopId != null ? '/store/${widget.shopId}' : null;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to join the queue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/login',
                  arguments: returnTo != null ? {'returnTo': returnTo} : null,
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final result = await _queueService.joinQueue(queue.qid);

      if (!mounted) return;

      // Navigate to queue status page with the queue data
      Navigator.pushNamed(
        context,
        '/queue-status',
        arguments: {
          'queueId': queue.qid,
          'queueData': result,
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error dialog instead of setting error state
      ErrorDialog.show(
        context,
        title: 'Unable to Join Queue',
        message: ErrorDialog.getErrorMessage(e),
        buttonText: 'Try Again',
        onPressed: () {
          Navigator.of(context).pop();
          _joinQueue(queue); // Retry joining
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: widget.queues.length,
      itemBuilder: (context, index) {
        final queue = widget.queues[index];
        return StoreQueueCard(
          queue: queue,
          onJoin: (queue.status == QueueStatus.active && !widget.userCurrentQueueIds.contains(queue.qid))
              ? () => _joinQueue(queue)
              : null,
          isJoining: _isJoining,
          isUserInQueue: widget.userCurrentQueueIds.contains(queue.qid),
        );
      },
    );
  }
}
