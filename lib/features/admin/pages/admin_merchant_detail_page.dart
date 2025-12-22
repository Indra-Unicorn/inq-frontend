import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../merchant/models/merchant_data.dart';

class AdminMerchantDetailPage extends StatelessWidget {
  final MerchantData merchant;

  const AdminMerchantDetailPage({
    super.key,
    required this.merchant,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREATED':
        return AppColors.info;
      case 'APPROVED':
        return AppColors.success;
      case 'BLOCKED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(merchant.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merchant Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Name', value: merchant.name),
                    _InfoRow(label: 'Email', value: merchant.email),
                    _InfoRow(label: 'Phone', value: merchant.phoneNumber),
                    _InfoRow(
                      label: 'inQoin',
                      value: merchant.inQoin.toStringAsFixed(1),
                    ),
                    _InfoRow(
                      label: 'Status',
                      value: merchant.status,
                      valueColor: _getStatusColor(merchant.status),
                    ),
                    _InfoRow(
                      label: 'Created At',
                      value: merchant.createdAt.toString().split('.')[0],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Shops List
            Text(
              'Shops (${merchant.shops.length})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...merchant.shops.map((shop) => _ShopCard(shop: shop)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopData shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final totalProcessed = shop.queueResponses.fold<int>(
      0,
      (sum, queue) => sum + queue.processed,
    );
    final totalSize = shop.queueResponses.fold<int>(
      0,
      (sum, queue) => sum + queue.size,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shop.shopName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: shop.isOpen
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shop.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: shop.isOpen ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shop Details
            _InfoRow(label: 'Phone', value: shop.shopPhoneNumber),
            _InfoRow(
              label: 'Address',
              value:
                  '${shop.address.streetAddress}, ${shop.address.city}, ${shop.address.state} ${shop.address.postalCode}',
            ),
            _InfoRow(
              label: 'Hours',
              value: '${shop.openTime} - ${shop.closeTime}',
            ),
            _InfoRow(
              label: 'Rating',
              value: shop.rating > 0
                  ? '${shop.rating.toStringAsFixed(1)} (${shop.ratingCount} reviews)'
                  : 'No ratings yet',
            ),
            _InfoRow(
              label: 'Categories',
              value: shop.categories.isEmpty
                  ? 'None'
                  : shop.categories.join(', '),
            ),
            const SizedBox(height: 12),

            // Queue Statistics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Total Processed',
                          value: totalProcessed.toString(),
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Total Queue Size',
                          value: totalSize.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Active Customers',
                          value: shop.activeCustomerCount.toString(),
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Avg Time/Customer',
                          value: '${shop.avgTimePerCustomer} min',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Queues List
            if (shop.queueResponses.isNotEmpty) ...[
              Text(
                'Queues (${shop.queueResponses.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...shop.queueResponses.map((queue) => _QueueItem(queue: queue)),
            ],

            // Images
            if (shop.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shop.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          shop.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.backgroundDark,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _QueueItem extends StatelessWidget {
  final QueueResponse queue;

  const _QueueItem({required this.queue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  queue.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: queue.status == 'ACTIVE'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  queue.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: queue.status == 'ACTIVE'
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QueueStat(
                  label: 'Size',
                  value: '${queue.size}/${queue.maxSize}',
                ),
              ),
              Expanded(
                child: _QueueStat(
                  label: 'Processed',
                  value: queue.processed.toString(),
                ),
              ),
              Expanded(
                child: _QueueStat(
                  label: 'inQoin Rate',
                  value: queue.inQoinRate.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueStat extends StatelessWidget {
  final String label;
  final String value;

  const _QueueStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

