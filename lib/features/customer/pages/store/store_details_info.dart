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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${store.address.streetAddress}, ${store.address.city}, ${store.address.state}',
                  style: CommonStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating and Status
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.rating.toString(),
                      style: CommonStyle.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' (${store.ratingCount})',
                      style: CommonStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: store.isOpen
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      store.isOpen ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: store.isOpen ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.isOpen ? 'Open' : 'Closed',
                      style: CommonStyle.bodySmall.copyWith(
                        color:
                            store.isOpen ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (store.isOpen && store.openTime != null && store.closeTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Hours: ${store.openTime} - ${store.closeTime}',
                style: CommonStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Categories
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: store.categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: CommonStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
