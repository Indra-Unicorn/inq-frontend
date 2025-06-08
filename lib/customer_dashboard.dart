import 'package:flutter/material.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  final List<String> categories = [
    'Grocery',
    'Pharmacy',
    'Electronics',
    'Home Goods',
    'Clothing',
  ];

  final List<Store> nearbyStores = [
    Store(
      name: 'Fresh Foods Market',
      distance: '1.2 miles away',
      address: '456 Oak Street, Downtown',
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=100&h=100&fit=crop',
    ),
    Store(
      name: 'Tech Haven',
      distance: '2.5 miles away',
      address: '123 Main Street, Anytown, USA',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=100&h=100&fit=crop',
    ),
    Store(
      name: 'Home Essentials',
      distance: '3.1 miles away',
      address: '789 Pine Avenue, Uptown',
      imageUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        // Navigate to profile
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: nearbyStores.length,
                itemBuilder: (context, index) {
                  final store = nearbyStores[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(store.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        store.name,
                        style: const TextStyle(
                          color: Color(0xFF181111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        store.distance,
                        style: const TextStyle(
                          color: Color(0xFF886364),
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to store details page
                        Navigator.pushNamed(
                          context, 
                          '/store-details',
                          arguments: {
                            'storeName': store.name,
                            'storeAddress': store.address,
                            'storeImage': store.imageUrl.replaceAll('w=100&h=100', 'w=600&h=300'),
                          },
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

class Store {
  final String name;
  final String distance;
  final String address;
  final String imageUrl;

  Store({
    required this.name,
    required this.distance,
    required this.address,
    required this.imageUrl,
  });
}