import 'package:flutter/material.dart';
import '../models/merchant_profile.dart';
import 'time_selector.dart';
import 'categories_selector.dart';
import 'shop_image_upload.dart';

class StoreDetailsCard extends StatelessWidget {
  final bool isEditMode;
  final MerchantShop? currentShop;
  final TextEditingController storeNameController;
  final TextEditingController storePhoneController;
  final TextEditingController storeAddressController;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final List<String> selectedCategories;
  final List<String> availableCategories;
  final ValueChanged<TimeOfDay> onOpenTimeChanged;
  final ValueChanged<TimeOfDay> onCloseTimeChanged;
  final ValueChanged<List<String>> onCategoriesChanged;
  final VoidCallback? onImageUploaded;

  const StoreDetailsCard({
    super.key,
    required this.isEditMode,
    required this.currentShop,
    required this.storeNameController,
    required this.storePhoneController,
    required this.storeAddressController,
    required this.openTime,
    required this.closeTime,
    required this.selectedCategories,
    required this.availableCategories,
    required this.onOpenTimeChanged,
    required this.onCloseTimeChanged,
    required this.onCategoriesChanged,
    this.onImageUploaded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, size: 24, color: Color(0xFFE9B8BA)),
                const SizedBox(width: 8),
                Text(
                  'Store Details',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEditMode) ...[
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Store Phone',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storeAddressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TimeSelector(
                      label: 'Opening Time',
                      time: openTime,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: openTime,
                        );
                        if (picked != null) onOpenTimeChanged(picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TimeSelector(
                      label: 'Closing Time',
                      time: closeTime,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: closeTime,
                        );
                        if (picked != null) onCloseTimeChanged(picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Categories',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CategoriesSelector(
                selectedCategories: selectedCategories,
                availableCategories: availableCategories,
                onCategoriesChanged: onCategoriesChanged,
              ),
              const SizedBox(height: 16),
              // Shop Image Upload Section
              ShopImageUpload(
                shop: currentShop,
                isEditMode: isEditMode,
                onImageUploaded: onImageUploaded,
              ),
            ] else ...[
              _buildReadOnlyRow('Store Name', currentShop?.shopName ?? ''),
              _buildReadOnlyRow(
                  'Store Phone', currentShop?.shopPhoneNumber ?? ''),
              _buildReadOnlyRow(
                  'Address', currentShop?.address.fullAddress ?? ''),
              _buildReadOnlyRow(
                  'Open Time', currentShop?.formattedOpenTime ?? ''),
              _buildReadOnlyRow(
                  'Close Time', currentShop?.formattedCloseTime ?? ''),
              _buildReadOnlyRow(
                  'Categories', currentShop?.categories.join(', ') ?? ''),
              _buildReadOnlyRow('Rating', currentShop?.ratingDisplay ?? ''),
              const SizedBox(height: 16),
              // Shop Image Upload Section (read-only view)
              ShopImageUpload(
                shop: currentShop,
                isEditMode: false,
                onImageUploaded: onImageUploaded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B5B5C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF191010),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
