import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  List<MerchantData> _merchants = [];

  final List<String> categories = [
    'All',
    'Food',
    'Retail',
    'Services',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get token from storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _error = 'Authentication token not found';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/merchant/get/all?status=APPROVED'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _merchants = (data['data'] as List)
                .map((item) => MerchantData.fromJson(item))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to fetch merchants';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized access
        setState(() {
          _error = 'Session expired. Please login again.';
          _isLoading = false;
        });
        // Optionally navigate to login page
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          _error = 'Failed to fetch merchants: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
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
                        onChanged: (value) {
                          // Implement search functionality
                        },
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
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchMerchants,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _merchants.isEmpty
                          ? const Center(child: Text('No stores found'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _merchants.length,
                              itemBuilder: (context, index) {
                                final merchant = _merchants[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFFF4F0F0),
                                        image: merchant
                                                .merchant.imageUrls.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  merchant
                                                      .merchant.imageUrls.first,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: merchant.merchant.imageUrls.isEmpty
                                          ? const Icon(
                                              Icons.store,
                                              color: Color(0xFF886364),
                                              size: 24,
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      merchant.merchant.shopName,
                                      style: const TextStyle(
                                        color: Color(0xFF181111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      merchant.merchant.address.streetAddress,
                                      style: const TextStyle(
                                        color: Color(0xFF886364),
                                        fontSize: 14,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/store-details',
                                        arguments: {
                                          'storeName':
                                              merchant.merchant.shopName,
                                          'storeAddress': merchant
                                              .merchant.address.streetAddress,
                                          'storeImage': merchant
                                                  .merchant.imageUrls.isNotEmpty
                                              ? merchant
                                                  .merchant.imageUrls.first
                                              : null,
                                          'queues': merchant.merchantQueues
                                              .map(
                                                (queue) => {
                                                  'id': queue.id,
                                                  'name': queue.name,
                                                  'merchantId':
                                                      queue.merchantId,
                                                  'merchantName':
                                                      queue.merchantName,
                                                  'status': queue.status,
                                                  'processed': queue.processed,
                                                  'size': queue.size,
                                                  'createdAt': queue.createdAt
                                                      .toIso8601String(),
                                                  'updatedAt': queue.updatedAt
                                                      .toIso8601String(),
                                                },
                                              )
                                              .toList(),
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
          border: Border(top: BorderSide(color: Color(0xFFF4F0F0), width: 1)),
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
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Queue'),
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

class MerchantData {
  final Merchant merchant;
  final List<MerchantQueue> merchantQueues;

  MerchantData({required this.merchant, required this.merchantQueues});

  factory MerchantData.fromJson(Map<String, dynamic> json) {
    return MerchantData(
      merchant: Merchant.fromJson(json['merchant']),
      merchantQueues: (json['merchantQueues'] as List)
          .map((queue) => MerchantQueue.fromJson(queue))
          .toList(),
    );
  }
}

class Merchant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String shopName;
  final Address address;
  final String status;
  final String userType;
  final List<String> imageUrls;

  Merchant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.shopName,
    required this.address,
    required this.status,
    required this.userType,
    required this.imageUrls,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      shopName: json['shopName'],
      address: Address.fromJson(json['address']),
      status: json['status'],
      userType: json['userType'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}

class Address {
  final String streetAddress;
  final double? latitude;
  final double? longitude;
  final String city;
  final String state;
  final String country;
  final String? postalCode;

  Address({
    required this.streetAddress,
    this.latitude,
    this.longitude,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      streetAddress: json['streetAddress'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }
}

class MerchantQueue {
  final String id;
  final String name;
  final String merchantId;
  final String merchantName;
  final String status;
  final int processed;
  final int size;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantQueue({
    required this.id,
    required this.name,
    required this.merchantId,
    required this.merchantName,
    required this.status,
    required this.processed,
    required this.size,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantQueue.fromJson(Map<String, dynamic> json) {
    return MerchantQueue(
      id: json['id'],
      name: json['name'],
      merchantId: json['merchantId'],
      merchantName: json['merchantName'],
      status: json['status'],
      processed: json['processed'],
      size: json['size'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
