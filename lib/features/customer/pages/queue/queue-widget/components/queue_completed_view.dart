import 'package:flutter/material.dart';
import '../../../../../../shared/common_style.dart';
import '../../../../../../shared/constants/app_colors.dart';

class QueueCompletedView extends StatelessWidget {
  final String queueName;
  final String message;
  final VoidCallback onBackPressed;

  const QueueCompletedView({
    super.key,
    required this.queueName,
    required this.message,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: CommonStyle.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Queue: $queueName',
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onBackPressed,
            style: CommonStyle.primaryButton,
            child: const Text('Back to Queues'),
          ),
        ],
      ),
    );
  }
}
