import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart';

class StoreDetailsInfo extends StatelessWidget {
  final Shop store;

  const StoreDetailsInfo({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Information',
                      style: CommonStyle.heading4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Details and contact information',
                      style: CommonStyle.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.access_time_outlined,
            label: 'Status',
            value: store.shopStatus,
            valueColor: store.statusColor,
          ),
          if (store.openTime != null && store.closeTime != null)
            _buildInfoRow(
              icon: Icons.schedule_outlined,
              label: 'Hours',
              value: '${store.openTime} - ${store.closeTime}',
            ),
          if (store.shopPhoneNumber != null)
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: store.shopPhoneNumber!,
              isClickable: true,
            ),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: _formatAddress(store.address),
          ),
          if (store.rating > 0)
            _buildInfoRow(
              icon: Icons.star_outline,
              label: 'Rating',
              value:
                  '${store.rating.toStringAsFixed(1)} (${store.ratingCount} reviews)',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CommonStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: CommonStyle.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight:
                        isClickable ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(ShopAddress address) {
    final parts = <String>[];
    if (address.streetAddress.isNotEmpty) parts.add(address.streetAddress);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.state.isNotEmpty) parts.add(address.state);
    if (address.postalCode.isNotEmpty) parts.add(address.postalCode);

    return parts.join(', ');
  }
}
