import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class CustomerDashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const CustomerDashboardSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.search,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search for stores',
                  hintStyle: CommonStyle.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: CommonStyle.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
