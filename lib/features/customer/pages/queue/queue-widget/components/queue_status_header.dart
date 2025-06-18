import 'package:flutter/material.dart';
import '../../../../../../shared/common_style.dart';
import '../../../../../../shared/constants/app_colors.dart';

class QueueStatusHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const QueueStatusHeader({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 48,
              height: 48,
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Queue Status',
              style: CommonStyle.heading3,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }
}
