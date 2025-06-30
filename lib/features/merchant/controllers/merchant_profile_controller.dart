import 'package:flutter/material.dart';
import '../models/merchant_profile.dart';
import '../services/merchant_profile_service.dart';

class MerchantProfileController extends ChangeNotifier {
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isEditMode = false;
  MerchantProfileData? _merchantProfile;
  MerchantShop? _currentShop;

  // Controllers
  final TextEditingController merchantNameController = TextEditingController();
  final TextEditingController merchantEmailController = TextEditingController();
  final TextEditingController merchantPhoneController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storePhoneController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();

  // State
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

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isEditMode => _isEditMode;
  MerchantProfileData? get merchantProfile => _merchantProfile;
  MerchantShop? get currentShop => _currentShop;
  TimeOfDay get openTime => _openTime;
  TimeOfDay get closeTime => _closeTime;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get availableCategories => _availableCategories;

  @override
  void dispose() {
    merchantNameController.dispose();
    merchantEmailController.dispose();
    merchantPhoneController.dispose();
    storeNameController.dispose();
    storePhoneController.dispose();
    storeAddressController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      final profile = await MerchantProfileService.getMerchantProfile();
      final shop = profile.primaryShop;

      _merchantProfile = profile;
      _currentShop = shop;

      // Initialize controllers
      merchantNameController.text = profile.name;
      merchantEmailController.text = profile.email;
      merchantPhoneController.text = profile.phoneNumber;

      if (shop != null) {
        storeNameController.text = shop.shopName;
        storePhoneController.text = shop.shopPhoneNumber;
        storeAddressController.text = shop.address.fullAddress;
        _openTime = shop.openTimeOfDay;
        _closeTime = shop.closeTimeOfDay;
        _selectedCategories = List<String>.from(shop.categories);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveProfile() async {
    if (_merchantProfile == null || _currentShop == null) return;

    _setUpdating(true);
    try {
      await MerchantProfileService.updateMerchantProfile(
        name: merchantNameController.text.trim(),
        email: merchantEmailController.text.trim(),
        phoneNumber: merchantPhoneController.text.trim(),
        shopName: storeNameController.text.trim(),
        shopPhoneNumber: storePhoneController.text.trim(),
        address: _currentShop!.address,
        isOpen: _currentShop!.isOpen,
        openTime: _openTime,
        closeTime: _closeTime,
        categories: _selectedCategories,
        images: _currentShop!.images,
        shopMetadata: _currentShop!.metadata,
      );

      _setEditMode(false);
      await loadProfile();
    } catch (e) {
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  void toggleEditMode() {
    _setEditMode(!_isEditMode);
  }

  void updateOpenTime(TimeOfDay time) {
    _openTime = time;
    notifyListeners();
  }

  void updateCloseTime(TimeOfDay time) {
    _closeTime = time;
    notifyListeners();
  }

  void updateCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setEditMode(bool editMode) {
    _isEditMode = editMode;
    notifyListeners();
  }
}
