import 'package:flutter/material.dart';
import '../models/merchant_profile.dart';

class MerchantDetailsCard extends StatelessWidget {
  final bool isEditMode;
  final MerchantProfileData? merchantProfile;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const MerchantDetailsCard({
    super.key,
    required this.isEditMode,
    required this.merchantProfile,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
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
                const Icon(Icons.person, size: 24, color: Color(0xFFE9B8BA)),
                const SizedBox(width: 8),
                Text(
                  'Merchant Details',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEditMode) ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
            ] else ...[
              _buildReadOnlyRow('Name', merchantProfile?.name ?? ''),
              _buildReadOnlyRow('Email', merchantProfile?.email ?? ''),
              _buildReadOnlyRow('Phone', merchantProfile?.phoneNumber ?? ''),
            ],
            // Status is always read-only (managed by backend)
            _buildReadOnlyRow('Status', merchantProfile?.statusDisplay ?? ''),
            _buildReadOnlyRow(
              'InQoin',
              '${merchantProfile?.formattedInQoin ?? '0.00'} Qoins',
            ),
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
