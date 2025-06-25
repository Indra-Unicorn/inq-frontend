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
import '../../../../services/notification_service.dart';
import '../../services/profile_service.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ShopService _shopService = ShopService();
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;
  List<Shop> _stores = [];
  bool _locationChecked = false;

  // Search state
  List<Shop> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchTray = false;
  bool _searchLoading = false;
  String? _searchError;
  double? _userLat;
  double? _userLong;
  DateTime? _lastSearchTime;

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
    _checkAndUpdateLocation();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchTray = false;
        _searchError = null;
      });
      return;
    }
    _debouncedSearch(query);
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      setState(() {
        _showSearchTray = false;
      });
    } else if (_searchResults.isNotEmpty) {
      setState(() {
        _showSearchTray = true;
      });
    }
  }

  void _debouncedSearch(String query) async {
    final now = DateTime.now();
    if (_lastSearchTime != null &&
        now.difference(_lastSearchTime!) < Duration(milliseconds: 400)) {
      return;
    }
    _lastSearchTime = now;
    setState(() {
      _searchLoading = true;
      _searchError = null;
    });
    try {
      final results = await _shopService.searchShops(
        search: query,
        latitude: _userLat,
        longitude: _userLong,
      );
      setState(() {
        _searchResults = results;
        _showSearchTray = true;
        _searchLoading = false;
        _searchError = null;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _showSearchTray = true;
        _searchLoading = false;
        _searchError = e.toString();
      });
    }
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

  Future<void> _checkAndUpdateLocation() async {
    if (_locationChecked) return;
    _locationChecked = true;
    final locationService = LocationService();
    final profileService = ProfileService();
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      _userLat = position.latitude;
      _userLong = position.longitude;
      try {
        await profileService.updateCustomerLocation(
            latitude: position.latitude, longitude: position.longitude);
      } catch (e) {
        print("Error updating location: $e");
      }
    } else {
      try {
        await profileService.updateCustomerLocation(); // Call with no location
      } catch (e) {
        print("Error updating location: $e");
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onStoreTap(Shop store) {
    Navigator.pushNamed(
      context,
      '/store-details',
      arguments: store,
    );
    setState(() {
      _showSearchTray = false;
      _searchController.clear();
    });
  }

  void _onProfileTap() {
    Navigator.pushNamed(context, '/customer-profile');
  }

  void _onHistoryTap() {
    Navigator.pushNamed(context, '/queue-status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return Center(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 0),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        CustomerDashboardHeader(onProfileTap: _onProfileTap),
                        if (!_showSearchTray)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 8),
                                    child: Icon(
                                      Icons.search,
                                      color: AppColors.secondary,
                                      size: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Search for stores',
                                        hintStyle:
                                            CommonStyle.bodyMedium.copyWith(
                                          color: AppColors.secondary,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 14),
                                      ),
                                      style: CommonStyle.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                  : _buildResponsiveStoreList(isDesktop),
                        ),
                      ],
                    ),
                    if (_showSearchTray &&
                        (_searchResults.isNotEmpty ||
                            _searchLoading ||
                            _searchError != null))
                      Positioned.fill(
                        child: Material(
                          color: Colors.white.withOpacity(0.98),
                          child: Column(
                            children: [
                              // Search bar at the top of the tray
                              SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 56, 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, right: 8),
                                                child: Icon(
                                                  Icons.search,
                                                  color: AppColors.secondary,
                                                  size: 24,
                                                ),
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  controller: _searchController,
                                                  focusNode: _searchFocusNode,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Search for stores',
                                                    hintStyle: CommonStyle
                                                        .bodyMedium
                                                        .copyWith(
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 14),
                                                  ),
                                                  style: CommonStyle.bodyLarge,
                                                  autofocus: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
                                            size: 28, color: Colors.black87),
                                        onPressed: () {
                                          setState(() {
                                            _showSearchTray = false;
                                            _searchController.clear();
                                            _searchFocusNode.unfocus();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Results below
                              Expanded(
                                child: _searchLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : _searchError != null
                                        ? Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Text(_searchError!,
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          )
                                        : ListView.separated(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 8),
                                            itemCount: _searchResults.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(height: 1),
                                            itemBuilder: (context, index) {
                                              final shop =
                                                  _searchResults[index];
                                              return ListTile(
                                                leading: shop.images.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Image.network(
                                                          shop.images.first,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .backgroundLight,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Icon(
                                                            Icons.store,
                                                            color: AppColors
                                                                .primary),
                                                      ),
                                                title: Text(
                                                  shop.shopName,
                                                  style: CommonStyle.bodyLarge,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  shop.categories.isNotEmpty
                                                      ? shop.categories
                                                          .join(', ')
                                                      : '',
                                                  style: CommonStyle.bodySmall
                                                      .copyWith(
                                                          color: AppColors
                                                              .textSecondary),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                onTap: () => _onStoreTap(shop),
                                              );
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomerDashboardBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            _onHistoryTap();
          } else if (index == 2) {
            _onProfileTap();
          }
        },
      ),
    );
  }

  Widget _buildResponsiveStoreList(bool isDesktop) {
    if (isDesktop) {
      // Use a grid for desktop
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          return CustomerDashboardStoreList(
            stores: [_stores[index]],
            onStoreTap: _onStoreTap,
          );
        },
      );
    } else {
      // Use the existing list for mobile
      return CustomerDashboardStoreList(
        stores: _stores,
        onStoreTap: _onStoreTap,
      );
    }
  }
}
