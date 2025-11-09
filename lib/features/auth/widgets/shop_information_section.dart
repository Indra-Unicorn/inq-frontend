import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../validators/merchant_signup_validator.dart';

class ShopInformationSection extends StatelessWidget {
  final TextEditingController shopNameController;
  final TextEditingController shopPhoneController;
  final TextEditingController streetAddressController;
  final TextEditingController postalCodeController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final String? location;
  final VoidCallback onGetLocation;

  const ShopInformationSection({
    super.key,
    required this.shopNameController,
    required this.shopPhoneController,
    required this.streetAddressController,
    required this.postalCodeController,
    required this.cityController,
    required this.stateController,
    required this.countryController,
    this.location,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Shop Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: shopNameController,
            label: 'Shop Name',
            hint: 'Enter your shop name',
            icon: Icons.store,
            validator: (value) =>
                MerchantSignupValidator.validateRequired(value, 'Shop name'),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: shopPhoneController,
            label: 'Shop Phone Number',
            hint: 'Enter shop contact number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: MerchantSignupValidator.validatePhone,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: streetAddressController,
            label: 'Street Address',
            hint: 'Enter street address',
            icon: Icons.location_on_outlined,
            validator: (value) => MerchantSignupValidator.validateRequired(
                value, 'Street address'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: postalCodeController,
                  label: 'Postal Code',
                  hint: 'Postal code',
                  icon: Icons.pin_drop_outlined,
                  validator: (value) =>
                      MerchantSignupValidator.validateRequired(value, 'Postal code'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: cityController,
                  label: 'City',
                  hint: 'City name',
                  icon: Icons.location_city_outlined,
                  validator: (value) =>
                      MerchantSignupValidator.validateRequired(value, 'City'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: stateController,
                  label: 'State',
                  hint: 'State/Province',
                  icon: Icons.map_outlined,
                  validator: (value) =>
                      MerchantSignupValidator.validateRequired(value, 'State'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: countryController,
                  label: 'Country',
                  hint: 'Country name',
                  icon: Icons.public_outlined,
                  validator: (value) =>
                      MerchantSignupValidator.validateRequired(
                          value, 'Country'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGetLocation,
              icon: Icon(
                Icons.my_location,
                color: AppColors.textWhite,
                size: 20,
              ),
              label: Text(
                location != null
                    ? 'Location Updated ✓'
                    : 'Get Current Location',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    location != null ? AppColors.success : AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (location != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location captured successfully',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon,
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
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
