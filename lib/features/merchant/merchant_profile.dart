import 'package:flutter/material.dart';
import 'controllers/merchant_profile_controller.dart';
import 'components/merchant_details_card.dart';
import 'components/store_details_card.dart';
import 'services/merchant_profile_service.dart';
import '../../shared/constants/app_colors.dart';

class MerchantProfile extends StatefulWidget {
  const MerchantProfile({super.key});

  @override
  State<MerchantProfile> createState() => _MerchantProfileState();
}

class _MerchantProfileState extends State<MerchantProfile> {
  late final MerchantProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MerchantProfileController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await _controller.loadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      await _controller.saveProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await MerchantProfileService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Merchant Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                  _controller.isEditMode ? Icons.close : Icons.edit_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: _controller.toggleEditMode,
                tooltip:
                    _controller.isEditMode ? 'Cancel Edit' : 'Edit Profile',
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Merchant Details Card
                  MerchantDetailsCard(
                    isEditMode: _controller.isEditMode,
                    merchantProfile: _controller.merchantProfile,
                    nameController: _controller.merchantNameController,
                    emailController: _controller.merchantEmailController,
                    phoneController: _controller.merchantPhoneController,
                  ),
                  const SizedBox(height: 16),
                  // Store Details Card (includes shop images)
                  StoreDetailsCard(
                    isEditMode: _controller.isEditMode,
                    currentShop: _controller.currentShop,
                    storeNameController: _controller.storeNameController,
                    storePhoneController: _controller.storePhoneController,
                    storeAddressController: _controller.storeAddressController,
                    openTime: _controller.openTime,
                    closeTime: _controller.closeTime,
                    selectedCategories: _controller.selectedCategories,
                    availableCategories: _controller.availableCategories,
                    onOpenTimeChanged: _controller.updateOpenTime,
                    onCloseTimeChanged: _controller.updateCloseTime,
                    onCategoriesChanged: _controller.updateCategories,
                    onImageUploaded: () async {
                      await _controller.refreshProfile();
                    },
                  ),
                  const SizedBox(height: 24),
                  // Logout Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _controller.isEditMode
              ? FloatingActionButton.extended(
                  onPressed: _controller.isUpdating ? null : _saveProfile,
                  icon: _controller.isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_controller.isUpdating ? 'Saving...' : 'Save'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
