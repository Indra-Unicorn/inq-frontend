import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class CustomerDashboardHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const CustomerDashboardHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Stores',
                      style: CommonStyle.heading2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect queue',
                      style: CommonStyle.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onProfileTap,
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  padding: const EdgeInsets.all(12),
                  tooltip: 'Profile',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
