import 'package:flutter/material.dart';
import '../models/merchant_data.dart';
import '../services/merchant_service.dart';

class CustomerDashboardViewModel extends ChangeNotifier {
  final MerchantService _merchantService;
  List<MerchantData> _merchants = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController searchController = TextEditingController();

  CustomerDashboardViewModel(this._merchantService);

  List<MerchantData> get merchants => _merchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMerchants() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _merchants = await _merchantService.getApprovedMerchants();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchMerchants(String query) {
    // Implement search functionality
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
