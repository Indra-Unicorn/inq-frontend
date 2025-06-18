import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;
  final ShopService _shopService = ShopService();
  List<Shop> _shops = [];
  bool _isLoading = true;
  String? _error;

  final List<String> categories = [
    'Grocery',
    'Pharmacy',
    'Electronics',
    'Home Goods',
    'Clothing',
  ];

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final shops = await _shopService.getAllShops();
      setState(() {
        _shops = shops;
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

  IconData _getStoreIcon(List<String> categories) {
    if (categories.isEmpty) return Icons.store;

    final category = categories.first.toLowerCase();
    if (category.contains('restaurant') || category.contains('food')) {
      return Icons.restaurant;
    } else if (category.contains('gym') || category.contains('fitness')) {
      return Icons.fitness_center;
    } else if (category.contains('salon') || category.contains('beauty')) {
      return Icons.face;
    } else if (category.contains('medical') || category.contains('pharmacy')) {
      return Icons.local_pharmacy;
    } else if (category.contains('grocery') || category.contains('market')) {
      return Icons.shopping_basket;
    } else if (category.contains('electronics') || category.contains('tech')) {
      return Icons.devices;
    } else if (category.contains('clothing') || category.contains('fashion')) {
      return Icons.shopping_bag;
    } else if (category.contains('home') || category.contains('furniture')) {
      return Icons.home;
    }
    return Icons.store;
  }

  Color _getStoreIconColor(List<String> categories) {
    if (categories.isEmpty) return const Color(0xFF886364);

    final category = categories.first.toLowerCase();
    if (category.contains('restaurant') || category.contains('food')) {
      return const Color(0xFFE57373);
    } else if (category.contains('gym') || category.contains('fitness')) {
      return const Color(0xFF81C784);
    } else if (category.contains('salon') || category.contains('beauty')) {
      return const Color(0xFFF06292);
    } else if (category.contains('medical') || category.contains('pharmacy')) {
      return const Color(0xFF4FC3F7);
    } else if (category.contains('grocery') || category.contains('market')) {
      return const Color(0xFFFFB74D);
    } else if (category.contains('electronics') || category.contains('tech')) {
      return const Color(0xFF9575CD);
    } else if (category.contains('clothing') || category.contains('fashion')) {
      return const Color(0xFF4DB6AC);
    } else if (category.contains('home') || category.contains('furniture')) {
      return const Color(0xFFA1887F);
    }
    return const Color(0xFF886364);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            CustomerDashboardHeader(
              onProfileTap: () {
                Navigator.pushNamed(context, '/customer-profile');
              },
            ),
            // Search Bar
            CustomerDashboardSearchBar(controller: _searchController),
            // Categories
            CustomerDashboardCategories(categories: categories),
            // Nearby Stores Section
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Nearby Stores',
                style: TextStyle(
                  color: Color(0xFF181111),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            // Store List
            Expanded(
              child: CustomerDashboardStoreList(
                shops: _shops,
                isLoading: _isLoading,
                error: _error,
                getStoreIcon: _getStoreIcon,
                getStoreIconColor: _getStoreIconColor,
                onStoreTap: (shop) {
                  final args = {
                    'shopId': shop.shopId,
                    'shopName': shop.shopName,
                    'storeAddress':
                        '${shop.address.city}, ${shop.address.state}',
                    'storeImage': shop.images.isNotEmpty
                        ? shop.images.first
                        : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=300&fit=crop',
                  };
                  print('Navigating to store details with args: $args');
                  print('Shop ID being passed: ${shop.shopId}');
                  Navigator.pushNamed(
                    context,
                    '/store-details',
                    arguments: args,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: CustomerDashboardBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/customer-queues');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/customer-profile');
          }
        },
      ),
    );
  }
}
