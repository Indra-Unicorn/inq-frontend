import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';

class CustomerDashboardStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> stores;
  final Function(Map<String, dynamic>) onStoreTap;

  const CustomerDashboardStoreList({
    super.key,
    required this.stores,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onStoreTap(store),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            store['name'][0],
                            style: CommonStyle.heading3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store['name'],
                              style: CommonStyle.heading4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store['address'],
                              style: CommonStyle.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.access_time,
                        '${store['waitTime']} min',
                      ),
                      _buildInfoItem(
                        Icons.people,
                        '${store['queueSize']} in queue',
                      ),
                      _buildInfoItem(
                        Icons.star,
                        store['rating'].toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: CommonStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
