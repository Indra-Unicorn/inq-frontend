import 'package:flutter/material.dart';
import 'package:inq/services/merchant_service.dart';
import 'package:provider/provider.dart';
import 'viewmodels/customer_dashboard_viewmodel.dart';
import 'models/merchant_data.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomerDashboardViewModel(
        MerchantService(),
      )..fetchMerchants(),
      child: const CustomerDashboardView(),
    );
  }
}

class CustomerDashboardView extends StatelessWidget {
  const CustomerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CustomerDashboardViewModel>();
    final categories = [
      'All',
      'Food',
      'Retail',
      'Services',
      'Other',
    ];

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
                        controller: viewModel.searchController,
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
                        onChanged: viewModel.searchMerchants,
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
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: viewModel.fetchMerchants,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : viewModel.merchants.isEmpty
                          ? const Center(child: Text('No stores found'))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: viewModel.merchants.length,
                              itemBuilder: (context, index) {
                                final merchant = viewModel.merchants[index];
                                return _buildMerchantListItem(
                                    context, merchant);
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMerchantListItem(BuildContext context, MerchantData merchant) {
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
            image: merchant.shops.first.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(merchant.shops.first.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: merchant.shops.first.images.isEmpty
              ? const Icon(
                  Icons.store,
                  color: Color(0xFF886364),
                  size: 24,
                )
              : null,
        ),
        title: Text(
          merchant.shops.first.shopName,
          style: const TextStyle(
            color: Color(0xFF181111),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          merchant.shops.first.address.streetAddress,
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
              'storeName': merchant.shops.first.shopName,
              'storeAddress': merchant.shops.first.address.streetAddress,
              'storeImage': merchant.shops.first.images.isNotEmpty
                  ? merchant.shops.first.images.first
                  : null,
              'queues': merchant.shops.first.metadata['queues'] != null
                  ? (merchant.shops.first.metadata['queues'] as String)
                      .split(',')
                      .map((queueStr) {
                      final queueData = queueStr.split(':');
                      return {
                        'id': queueData[0],
                        'name': queueData[1],
                        'merchantId': merchant.merchantId,
                        'merchantName': merchant.shops.first.shopName,
                        'status': queueData[2],
                        'processed': int.parse(queueData[3]),
                        'size': int.parse(queueData[4]),
                        'createdAt': DateTime.now().toIso8601String(),
                        'updatedAt': DateTime.now().toIso8601String(),
                      };
                    }).toList()
                  : [],
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF4F0F0), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
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
    );
  }
}
