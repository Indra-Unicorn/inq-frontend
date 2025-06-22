import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/merchant_profile.dart';
import 'services/merchant_profile_service.dart';
import 'components/profile_info_card.dart';
import 'components/time_selector.dart';
import 'components/categories_selector.dart';

class MerchantProfile extends StatefulWidget {
  const MerchantProfile({super.key});

  @override
  State<MerchantProfile> createState() => _MerchantProfileState();
}

class _MerchantProfileState extends State<MerchantProfile> {
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isEditMode = false;
  MerchantProfileData? _merchantProfile;
  MerchantShop? _currentShop;

  // Editable state
  final _merchantNameController = TextEditingController();
  final _merchantEmailController = TextEditingController();
  final _merchantPhoneController = TextEditingController();
  String _merchantStatus = 'APPROVED';
  String _merchantInQoin = '';

  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 17, minute: 0);
  List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Restaurant',
    'Gym',
    'Salon',
    'Spa',
    'Retail',
    'Cafe',
    'Bar',
    'Clinic',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadMerchantProfile();
  }

  Future<void> _loadMerchantProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profile = await MerchantProfileService.getMerchantProfile();
      final shop = profile.primaryShop;
      setState(() {
        _merchantProfile = profile;
        _currentShop = shop;
        _merchantNameController.text = profile.name;
        _merchantEmailController.text = profile.email;
        _merchantPhoneController.text = profile.phoneNumber;
        _merchantStatus = profile.status;
        _merchantInQoin = profile.inQoin.toStringAsFixed(2);
        if (shop != null) {
          _storeNameController.text = shop.shopName;
          _storePhoneController.text = shop.shopPhoneNumber;
          _storeAddressController.text = shop.address.fullAddress;
          _openTime = shop.openTimeOfDay;
          _closeTime = shop.closeTimeOfDay;
          _selectedCategories = List<String>.from(shop.categories);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading profile: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_merchantProfile == null || _currentShop == null) return;
    setState(() {
      _isUpdating = true;
    });
    try {
      await MerchantProfileService.updateMerchantProfile(
        name: _merchantNameController.text.trim(),
        email: _merchantEmailController.text.trim(),
        phoneNumber: _merchantPhoneController.text.trim(),
        shopName: _storeNameController.text.trim(),
        shopPhoneNumber: _storePhoneController.text.trim(),
        address: _currentShop!.address,
        isOpen: _currentShop!.isOpen,
        openTime: _openTime,
        closeTime: _closeTime,
        categories: _selectedCategories,
        images: _currentShop!.images,
        shopMetadata: _currentShop!.metadata,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Color(0xFFE8B4B7)),
        );
        setState(() {
          _isEditMode = false;
        });
        await _loadMerchantProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void dispose() {
    _merchantNameController.dispose();
    _merchantEmailController.dispose();
    _merchantPhoneController.dispose();
    _storeNameController.dispose();
    _storePhoneController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF9F9),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: AppBar(
        title: const Text('Merchant Profile'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF191010)),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Cancel Edit' : 'Edit Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Merchant Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 24, color: Color(0xFFE9B8BA)),
                          const SizedBox(width: 8),
                          Text('Merchant Details',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isEditMode) ...[
                        TextField(
                          controller: _merchantNameController,
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _merchantEmailController,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined)),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _merchantPhoneController,
                          decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone_outlined)),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _merchantStatus,
                          decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.verified_user_outlined)),
                          items: const [
                            DropdownMenuItem(
                                value: 'APPROVED', child: Text('Approved')),
                            DropdownMenuItem(
                                value: 'PENDING', child: Text('Pending')),
                            DropdownMenuItem(
                                value: 'REJECTED', child: Text('Rejected')),
                            DropdownMenuItem(
                                value: 'SUSPENDED', child: Text('Suspended')),
                          ],
                          onChanged: (val) => setState(
                              () => _merchantStatus = val ?? 'APPROVED'),
                        ),
                      ] else ...[
                        _buildReadOnlyRow('Name', _merchantProfile?.name ?? ''),
                        _buildReadOnlyRow(
                            'Email', _merchantProfile?.email ?? ''),
                        _buildReadOnlyRow(
                            'Phone', _merchantProfile?.phoneNumber ?? ''),
                        _buildReadOnlyRow(
                            'Status', _merchantProfile?.statusDisplay ?? ''),
                        _buildReadOnlyRow('InQoin',
                            '${_merchantProfile?.formattedInQoin ?? '0.00'} Qoins'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Store Details Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store,
                              size: 24, color: Color(0xFFE9B8BA)),
                          const SizedBox(width: 8),
                          Text('Store Details',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isEditMode) ...[
                        TextField(
                          controller: _storeNameController,
                          decoration: const InputDecoration(
                              labelText: 'Store Name',
                              prefixIcon: Icon(Icons.storefront_outlined)),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _storePhoneController,
                          decoration: const InputDecoration(
                              labelText: 'Store Phone',
                              prefixIcon: Icon(Icons.phone_android_outlined)),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _storeAddressController,
                          decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.location_on_outlined)),
                          minLines: 1,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TimeSelector(
                                label: 'Opening Time',
                                time: _openTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                      context: context, initialTime: _openTime);
                                  if (picked != null)
                                    setState(() => _openTime = picked);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TimeSelector(
                                label: 'Closing Time',
                                time: _closeTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _closeTime);
                                  if (picked != null)
                                    setState(() => _closeTime = picked);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Categories',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        CategoriesSelector(
                          selectedCategories: _selectedCategories,
                          availableCategories: _availableCategories,
                          onCategoriesChanged: (categories) =>
                              setState(() => _selectedCategories = categories),
                        ),
                      ] else ...[
                        _buildReadOnlyRow(
                            'Store Name', _currentShop?.shopName ?? ''),
                        _buildReadOnlyRow(
                            'Store Phone', _currentShop?.shopPhoneNumber ?? ''),
                        _buildReadOnlyRow(
                            'Address', _currentShop?.address.fullAddress ?? ''),
                        _buildReadOnlyRow(
                            'Open Time', _currentShop?.formattedOpenTime ?? ''),
                        _buildReadOnlyRow('Close Time',
                            _currentShop?.formattedCloseTime ?? ''),
                        _buildReadOnlyRow('Categories',
                            _currentShop?.categories.join(', ') ?? ''),
                        _buildReadOnlyRow(
                            'Rating', _currentShop?.ratingDisplay ?? ''),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _isUpdating ? null : _saveProfile,
              icon: _isUpdating
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Icon(Icons.save),
              label: Text(_isUpdating ? 'Saving...' : 'Save'),
              backgroundColor: const Color(0xFFE9B8BA),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
