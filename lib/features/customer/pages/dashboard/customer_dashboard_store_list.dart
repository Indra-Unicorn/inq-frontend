import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart'; // Assuming you have a Shop model

class CustomerDashboardStoreList extends StatelessWidget {
  final List<Shop> stores; // Changed to use Shop model
  final Function(Shop) onStoreTap;

  const CustomerDashboardStoreList({
    super.key,
    required this.stores,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const Center(
        child: Text(
          'No stores available.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return GestureDetector(
          onTap: () => onStoreTap(store),
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreHeader(store),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: _buildStoreInfo(store),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreHeader(Shop store) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: store.images.isNotEmpty
              ? Image.network(
                  store.images.first,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildOpenStatusChip(store.shopStatus, store.statusColor),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: _buildRatingChip(store.rating, store.ratingCount),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: const Icon(
        Icons.store,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }

  Widget _buildStoreInfo(Shop store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          store.shopName,
          style: CommonStyle.heading4.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                store.address.streetAddress,
                style: CommonStyle.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.borderLight),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: _buildInfoIconText(
              Icons.access_time_filled,
              store.avgEntryTimeMinutes > 0 
                  ? '~${store.avgEntryTimeMinutes} min'
                  : 'No data',
              AppColors.success,
            )),
            Expanded(
                child: _buildInfoIconText(
              Icons.people_alt,
              '${store.activeCustomerCount ?? 0} active',
              AppColors.info,
            )),
            Expanded(
                child: _buildInfoIconText(
              Icons.category,
              store.categories.isNotEmpty ? store.categories.first : 'General',
              AppColors.warning,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildOpenStatusChip(String status, Color statusColor) {
    return Chip(
      label: Text(
        status,
        style: CommonStyle.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: statusColor.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildRatingChip(double rating, int ratingCount) {
    return Chip(
      avatar: const Icon(Icons.star, color: Colors.white, size: 16),
      label: Text(
        '$rating ($ratingCount)',
        style: CommonStyle.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelPadding: const EdgeInsets.only(left: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildInfoIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: CommonStyle.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
