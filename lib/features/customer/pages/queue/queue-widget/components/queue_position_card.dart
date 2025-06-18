import 'package:flutter/material.dart';
import '../../../../../../shared/common_style.dart';
import '../../../../../../shared/constants/app_colors.dart';

class QueuePositionCard extends StatelessWidget {
  final int currentRank;
  final int currentQueueSize;

  const QueuePositionCard({
    super.key,
    required this.currentRank,
    required this.currentQueueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Text(
              'Your Position',
              style: CommonStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currentRank',
              style: CommonStyle.heading1.copyWith(
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'of $currentQueueSize people',
              style: CommonStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
