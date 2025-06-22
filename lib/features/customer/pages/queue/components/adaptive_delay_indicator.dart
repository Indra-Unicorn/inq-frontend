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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success.withOpacity(0.15),
              AppColors.success.withOpacity(0.08),
            ],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on,
              size: 12,
              color: AppColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              'Real-time',
              style: CommonStyle.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.12),
            AppColors.warning.withOpacity(0.06),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '${delay}s',
            style: CommonStyle.caption.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
