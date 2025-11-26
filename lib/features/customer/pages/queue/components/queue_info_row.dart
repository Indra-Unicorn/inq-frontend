import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../models/customer_queue_summary.dart';

class QueueInfoRow extends StatelessWidget {
  final dynamic queue;

  const QueueInfoRow({
    super.key,
    required this.queue,
  });

  String _formatJoinedTime(String? joinedTime) {
    if (joinedTime == null) return 'N/A';
    
    try {
      final dateTime = DateTime.parse(joinedTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinedPosition = (queue is CustomerQueue)
        ? queue.joinedPosition
        : (queue as CustomerPastQueue).joinedPosition;
    final inQoinCharged = (queue is CustomerQueue)
        ? queue.inQoinCharged
        : (queue as CustomerPastQueue).inQoinCharged;
    final joinedTime = (queue is CustomerQueue)
        ? queue.joinedTime
        : (queue as CustomerPastQueue).joinedTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // First Row: Joined Position and inQoin Charged
          Row(
            children: [
              // Joined Position
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.login,
                        size: 14,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joined Position',
                            style: CommonStyle.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '$joinedPosition',
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
              ),
              // Divider and inQoin Charged (only if charged > 0)
              if (inQoinCharged > 0) ...[
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.monetization_on,
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
                              'inQoin Charged',
                              style: CommonStyle.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '$inQoinCharged',
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
                ),
              ],
            ],
          ),
          // Add spacing between rows
          const SizedBox(height: 12),
          // Second Row: Joined Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joined Time',
                      style: CommonStyle.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _formatJoinedTime(joinedTime),
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
        ],
      ),
    );
  }
}