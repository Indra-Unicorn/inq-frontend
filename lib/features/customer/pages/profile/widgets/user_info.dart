import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class UserInfo extends StatelessWidget {
  final String? name;
  final String? createdAt;
  final String? phoneNumber;
  final int? inQoin;

  const UserInfo({
    super.key,
    this.name,
    this.createdAt,
    this.phoneNumber,
    this.inQoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name ?? 'User Name',
            style: CommonStyle.heading3,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, phoneNumber ?? 'Not provided'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, createdAt ?? 'Not provided'),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.monetization_on,
            '${inQoin ?? 0} inQoin',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: CommonStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
