import 'package:flutter/material.dart';
import 'models/shop.dart';
import 'services/shop_service.dart';

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
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Find a Store',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer-profile');
                      },
                      icon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF181111),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF886364),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search for stores',
                          hintStyle: TextStyle(
                            color: Color(0xFF886364),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF181111),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(
                        categories[index],
                        style: const TextStyle(
                          color: Color(0xFF181111),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFFF4F0F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _shops.length,
                          itemBuilder: (context, index) {
                            final shop = _shops[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFFF4F0F0),
                                    image: shop.images.isNotEmpty && shop.images.first.startsWith('http')
                                        ? DecorationImage(
                                            image: NetworkImage(shop.images.first),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: shop.images.isEmpty || !shop.images.first.startsWith('http')
                                      ? Icon(
                                          _getStoreIcon(shop.categories),
                                          color: _getStoreIconColor(shop.categories),
                                          size: 28,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  shop.shopName,
                                  style: const TextStyle(
                                    color: Color(0xFF181111),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${shop.address.city}, ${shop.address.state}',
                                      style: const TextStyle(
                                        color: Color(0xFF886364),
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (shop.isOpen)
                                      const Text(
                                        'Open',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'Closed',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  final args = {
                                    'shopId': shop.shopId,
                                    'shopName': shop.shopName,
                                    'storeAddress': '${shop.address.city}, ${shop.address.state}',
                                    'storeImage': shop.images.isNotEmpty ? shop.images.first : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=300&fit=crop',
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF4F0F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
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
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF181111),
          unselectedItemColor: const Color(0xFF886364),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'My Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}