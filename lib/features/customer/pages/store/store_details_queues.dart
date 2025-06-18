import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/queue.dart';
import '../../models/queue_status.dart';

class StoreDetailsQueues extends StatelessWidget {
  final List<Queue> queues;
  final Function(Queue) onQueueTap;

  const StoreDetailsQueues({
    super.key,
    required this.queues,
    required this.onQueueTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final queue = queues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => onQueueTap(queue),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          queue.name,
                          style: CommonStyle.heading4,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(queue.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            queue.status.toString().split('.').last,
                            style: CommonStyle.bodySmall.copyWith(
                              color: _getStatusColor(queue.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          Icons.people,
                          '${queue.size}/${queue.maxSize} in queue',
                        ),
                        _buildInfoItem(
                          Icons.timer,
                          '${queue.processingRate} min per person',
                        ),
                        _buildInfoItem(
                          Icons.attach_money,
                          '${queue.inQoinRate} Qoins',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => onQueueTap(queue),
                      style: CommonStyle.primaryButton,
                      child: const Text('Join Queue'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: queues.length,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: CommonStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.active:
        return AppColors.success;
      case QueueStatus.paused:
        return AppColors.warning;
      case QueueStatus.closed:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
