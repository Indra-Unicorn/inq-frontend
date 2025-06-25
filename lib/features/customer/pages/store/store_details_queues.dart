import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/queue.dart';
import '../../models/queue_status.dart';
import '../../services/queue_service.dart';

class StoreQueueCard extends StatelessWidget {
  final Queue queue;
  final VoidCallback? onJoin;
  final bool isJoining;

  const StoreQueueCard({
    required this.queue,
    this.onJoin,
    this.isJoining = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    queue.name,
                    style: CommonStyle.heading3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(queue.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(queue.status),
                    style: CommonStyle.caption.copyWith(
                      color: _getStatusColor(queue.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Queue Size', '${queue.size}/${queue.maxSize}'),
            _buildDetailRow('Processing Rate', '${queue.processingRate}/min'),
            _buildDetailRow('inQoin Rate', '${queue.inQoinRate} Qoins'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (queue.status == QueueStatus.active &&
                        onJoin != null &&
                        !isJoining)
                    ? onJoin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isJoining
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Join Queue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  const StoreDetailsQueues({
    super.key,
    required this.queues,
  });

  @override
  State<StoreDetailsQueues> createState() => _StoreDetailsQueuesState();
}

class _StoreDetailsQueuesState extends State<StoreDetailsQueues> {
  final QueueService _queueService = QueueService();
  bool _isJoining = false;
  String? _error;

  Future<void> _joinQueue(Queue queue) async {
    setState(() {
      _isJoining = true;
      _error = null;
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
      setState(() {
        _error = e.toString();
      });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _error!,
              style: CommonStyle.errorTextStyle,
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemCount: widget.queues.length,
          itemBuilder: (context, index) {
            final queue = widget.queues[index];
            return StoreQueueCard(
              queue: queue,
              onJoin: queue.status == QueueStatus.active
                  ? () => _joinQueue(queue)
                  : null,
              isJoining: _isJoining,
            );
          },
        ),
      ],
    );
  }
}
