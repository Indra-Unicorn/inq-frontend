import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';
import 'customer_dashboard_header.dart';
import 'customer_dashboard_search_bar.dart';
import 'customer_dashboard_categories.dart';
import 'customer_dashboard_store_list.dart';
import 'customer_dashboard_bottom_nav.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ShopService _shopService = ShopService();
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;
  List<Shop> _stores = [];

  final List<String> _categories = [
    'All',
    'Food',
    'Shopping',
    'Services',
    'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final stores = await _shopService.getAllShops();
      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreTap(Shop store) {
    Navigator.pushNamed(
      context,
      '/store-details',
      arguments: store,
    );
  }

  void _onProfileTap() {
    Navigator.pushNamed(context, '/customer-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomerDashboardHeader(onProfileTap: _onProfileTap),
            CustomerDashboardSearchBar(controller: _searchController),
            CustomerDashboardCategories(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: CommonStyle.errorTextStyle,
                          ),
                        )
                      : CustomerDashboardStoreList(
                          stores: _stores
                              .map((shop) => {
                                    'name': shop.shopName,
                                    'address':
                                        '${shop.address.city}, ${shop.address.state}',
                                    'waitTime':
                                        15, // Default value since it's not in the model
                                    'queueSize':
                                        5, // Default value since it's not in the model
                                    'rating': shop.rating,
                                  })
                              .toList(),
                          onStoreTap: (store) => _onStoreTap(_stores.firstWhere(
                            (s) => s.shopName == store['name'],
                          )),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerDashboardBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            _onProfileTap();
          }
        },
      ),
    );
  }
}
