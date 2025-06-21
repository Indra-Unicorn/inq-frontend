import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../services/polling_config.dart';

class AdaptiveDelayIndicator extends StatelessWidget {
  final int currentPosition;

  const AdaptiveDelayIndicator({
    super.key,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    final delay = PollingConfig.getAdaptiveDelay(currentPosition);

    if (delay == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          'Real-time',
          style: CommonStyle.caption.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
            fontSize: 9,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${delay}s',
        style: CommonStyle.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }
}
