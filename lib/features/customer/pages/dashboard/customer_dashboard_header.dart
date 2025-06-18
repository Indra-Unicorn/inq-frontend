import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class CustomerDashboardHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const CustomerDashboardHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Find a Store',
              style: CommonStyle.heading4,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onProfileTap,
              icon: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
