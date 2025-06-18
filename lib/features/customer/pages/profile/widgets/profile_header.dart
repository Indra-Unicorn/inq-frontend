import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const ProfileHeader({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              'Profile',
              style: CommonStyle.heading4,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }
}
