import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';

class StatsSummaryCard extends StatelessWidget {
  final int totalQueues;
  final int activeQueues;
  final int totalCustomers;

  const StatsSummaryCard({
    super.key,
    required this.totalQueues,
    required this.activeQueues,
    required this.totalCustomers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.queue,
            label: 'Total Queues',
            value: totalQueues.toString(),
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            icon: Icons.play_circle_filled,
            label: 'Active',
            value: activeQueues.toString(),
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            icon: Icons.people,
            label: 'Total Customers',
            value: totalCustomers.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textWhite,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textWhite.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
