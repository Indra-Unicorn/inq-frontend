import 'package:flutter/material.dart';
import '../../../../../../shared/common_style.dart';
import '../../../../../../shared/constants/app_colors.dart';

class QueueDetailsCard extends StatelessWidget {
  final Map<String, dynamic> queueData;

  const QueueDetailsCard({
    super.key,
    required this.queueData,
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
              'Queue Details',
              style: CommonStyle.heading4,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Joined Position', '${queueData['joinedPosition']}'),
            if (queueData['comment'] != null)
              _buildDetailRow('Comment', queueData['comment']),
            if (queueData['inQoinCharged'] > 0)
              _buildDetailRow(
                  'inQoin Charged', '${queueData['inQoinCharged']}'),
            _buildDetailRow('Processed', '${queueData['processed']}'),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
