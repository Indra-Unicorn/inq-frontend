import 'package:flutter/material.dart';
import '../models/merchant_profile.dart';
import 'time_selector.dart';
import 'categories_selector.dart';
import 'shop_image_upload.dart';
import '../../../shared/constants/app_colors.dart';

class StoreDetailsCard extends StatelessWidget {
  final bool isEditMode;
  final MerchantShop? currentShop;
  final TextEditingController storeNameController;
  final TextEditingController storePhoneController;
  final TextEditingController streetAddressController;
  final TextEditingController postalCodeController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
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
    required this.streetAddressController,
    required this.postalCodeController,
    required this.cityController,
    required this.stateController,
    required this.countryController,
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    size: 20,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Store Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isEditMode) ...[
              TextField(
                controller: storeNameController,
                decoration: InputDecoration(
                  labelText: 'Store Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: storePhoneController,
                decoration: InputDecoration(
                  labelText: 'Store Phone',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.phone_android_outlined, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // Address Section Header
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Address',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Street Address
              TextField(
                controller: streetAddressController,
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.home_outlined, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // City and Postal Code Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: postalCodeController,
                      decoration: InputDecoration(
                        labelText: 'Postal Code',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // State and Country Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.map_outlined, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: countryController,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.public_outlined, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              _buildReadOnlyRow(Icons.storefront_outlined, 'Store Name', currentShop?.shopName ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.phone_android_outlined, 'Store Phone', currentShop?.shopPhoneNumber ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.location_on_outlined, 'Address', currentShop?.address.fullAddress ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.access_time_outlined, 'Open Time', currentShop?.formattedOpenTime ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.access_time_filled_outlined, 'Close Time', currentShop?.formattedCloseTime ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.category_outlined, 'Categories', currentShop?.categories.join(', ') ?? ''),
              _buildDivider(),
              _buildReadOnlyRow(Icons.star_outline, 'Rating', currentShop?.ratingDisplay ?? ''),
              const SizedBox(height: 20),
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

  Widget _buildReadOnlyRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }
}
