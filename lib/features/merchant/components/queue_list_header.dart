import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class QueueListHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;

  const QueueListHeader({
    super.key,
    required this.title,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.015,
            ),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Refresh',
            ),
        ],
      ),
    );
  }
}
