import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class LastUpdateIndicator extends StatelessWidget {
  final DateTime? lastUpdateTime;

  const LastUpdateIndicator({
    super.key,
    this.lastUpdateTime,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdateTime == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdateTime!);

    String timeText;
    if (difference.inSeconds < 60) {
      timeText = '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else {
      timeText = '${difference.inHours}h ago';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Updated $timeText',
            style: CommonStyle.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
