import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final String? addButtonTooltip;

  const DashboardHeader({
    super.key,
    required this.title,
    this.onAddPressed,
    this.addButtonTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (onAddPressed != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onAddPressed,
                tooltip: addButtonTooltip ?? 'Add',
                icon: Icon(
                  Icons.add,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
