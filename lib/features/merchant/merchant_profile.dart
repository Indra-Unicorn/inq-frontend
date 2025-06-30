import 'package:flutter/material.dart';
import 'controllers/merchant_profile_controller.dart';
import 'components/merchant_details_card.dart';
import 'components/store_details_card.dart';
import 'components/shop_image_upload.dart';
import 'services/merchant_profile_service.dart';

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
            backgroundColor: Colors.red,
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
            backgroundColor: Color(0xFFE8B4B7),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: AppBar(
        title: const Text('Merchant Profile'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF191010)),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return IconButton(
                icon: Icon(_controller.isEditMode ? Icons.close : Icons.edit),
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
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                  // Store Details Card
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
                  ),
                  const SizedBox(height: 16),
                  // Shop Image Upload Card
                  ShopImageUpload(
                    shop: _controller.currentShop,
                    isEditMode: _controller.isEditMode,
                    onImageUploaded: () async {
                      await _controller.refreshProfile();
                    },
                  ),
                  const SizedBox(height: 32),
                  // Logout Button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9242A),
                      foregroundColor: const Color(0xFFFCF8F8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.015,
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
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(Icons.save),
                  label: Text(_controller.isUpdating ? 'Saving...' : 'Save'),
                  backgroundColor: const Color(0xFFE9B8BA),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
