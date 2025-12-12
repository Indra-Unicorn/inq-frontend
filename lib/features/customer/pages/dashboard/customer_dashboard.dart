import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';
import 'customer_dashboard_header.dart';
import 'customer_dashboard_store_list.dart';
import 'customer_dashboard_bottom_nav.dart';
import '../../../../services/notification_service.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../../services/profile_service.dart';
import '../../../../services/auth_service.dart';

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
    // Only show search tray when focus is gained and there are results
    // Don't hide it when focus is lost - let user interact with results
    if (_searchFocusNode.hasFocus && _searchResults.isNotEmpty) {
      setState(() {
        _showSearchTray = true;
      });
    }
  }

  void _debouncedSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchTray = false;
        _searchError = null;
        _searchLoading = false;
      });
      return;
    }

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
      if (mounted) {
        setState(() {
          _searchResults = results;
          _showSearchTray = true;
          _searchLoading = false;
          _searchError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _showSearchTray = true;
          _searchLoading = false;
          _searchError = e.toString();
        });
      }
    }
  }

  Future<void> _loadStores() async {
    try {
      final stores = await _shopService.getAllShops();
      if (mounted) {
        setState(() {
          _stores = stores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error dialog for loading stores
        ErrorDialog.show(
          context,
          title: 'Unable to Load Stores',
          message: ErrorDialog.getErrorMessage(e),
          buttonText: 'Retry',
          onPressed: () {
            Navigator.of(context).pop();
            _loadStores(); // Retry loading stores
          },
        );
      }
    }
  }

  Future<void> _checkAndUpdateLocation() async {
    if (_locationChecked) return;
    _locationChecked = true;

    try {
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
          // Silently handle location update error
        }
      } else {
        try {
          await profileService
              .updateCustomerLocation(); // Call with no location
        } catch (e) {
          // Silently handle location update error
        }
      }
    } catch (e) {
      // Continue without location
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onStoreTap(Shop store) {
    // Always navigate with shop ID to ensure URL consistency
    Navigator.pushNamed(
      context,
      '/store/${store.shopId}',
    );
    setState(() {
      _showSearchTray = false;
      _searchController.clear();
    });
  }

  void _onProfileTap() async {
    // Check if user is logged in before accessing profile
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to access your profile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/customer-profile');
  }

  void _onHistoryTap() async {
    // Check if user is logged in before accessing queue history
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to view your queue history.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }
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
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Search stores, categories...',
                                  hintStyle: CommonStyle.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: CommonStyle.bodyLarge,
                              ),
                            ),
                          ),
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Loading stores...',
                                        style: CommonStyle.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildResponsiveStoreList(isDesktop),
                        ),
                      ],
                    ),
                    if (_showSearchTray)
                      Positioned.fill(
                        child: Material(
                          color: Colors.white,
                          child: Column(
                            children: [
                              // Search bar at the top of the tray (always visible)
                              SafeArea(
                                bottom: false,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadowLight.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundLight,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.shadowLight.withValues(alpha: 0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: _searchController,
                                              focusNode: _searchFocusNode,
                                              decoration: InputDecoration(
                                                hintText: 'Search stores, categories...',
                                                hintStyle: CommonStyle.bodyMedium.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                                prefixIcon: Container(
                                                  padding: const EdgeInsets.all(12),
                                                  child: Icon(
                                                    Icons.search_rounded,
                                                    color: AppColors.primary,
                                                    size: 24,
                                                  ),
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                              ),
                                              style: CommonStyle.bodyLarge,
                                              autofocus: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              size: 24,
                                              color: AppColors.textPrimary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showSearchTray = false;
                                                _searchController.clear();
                                                _searchFocusNode.unfocus();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        : _searchResults.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(24),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.backgroundLight,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.search_off_rounded,
                                                        size: 64,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'No stores found',
                                                      style: CommonStyle.heading4.copyWith(
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Try different keywords',
                                                      style: CommonStyle.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                itemCount:
                                                    _searchResults.length,
                                                itemBuilder: (context, index) {
                                                  if (index >=
                                                      _searchResults.length) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  final shop =
                                                      _searchResults[index];
                                                  return Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/store/${shop.shopId}',
                                                        ).then((_) {
                                                          if (mounted) {
                                                            setState(() {
                                                              _showSearchTray = false;
                                                              _searchController.clear();
                                                              _searchFocusNode.unfocus();
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 16,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 56,
                                                              height: 56,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(16),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: AppColors.shadowLight.withValues(alpha: 0.1),
                                                                    blurRadius: 8,
                                                                    offset: const Offset(0, 2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(16),
                                                                child: shop.images.isNotEmpty
                                                                    ? Image.network(
                                                                        shop.images.first,
                                                                        width: 56,
                                                                        height: 56,
                                                                        fit: BoxFit.cover,
                                                                        errorBuilder: (context, error, stackTrace) =>
                                                                            Container(
                                                                          width: 56,
                                                                          height: 56,
                                                                          decoration: BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                AppColors.primary.withValues(alpha: 0.1),
                                                                                AppColors.primaryLight.withValues(alpha: 0.1),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          child: const Icon(
                                                                            Icons.store_rounded,
                                                                            color: AppColors.primary,
                                                                            size: 28,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        width: 56,
                                                                        height: 56,
                                                                        decoration: BoxDecoration(
                                                                          gradient: LinearGradient(
                                                                            colors: [
                                                                              AppColors.primary.withValues(alpha: 0.1),
                                                                              AppColors.primaryLight.withValues(alpha: 0.1),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons.store_rounded,
                                                                          color: AppColors.primary,
                                                                          size: 28,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 16),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    shop.shopName,
                                                                    style: CommonStyle.bodyLarge.copyWith(
                                                                      fontWeight: FontWeight.w600,
                                                                      color: AppColors.textPrimary,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  if (shop.categories.isNotEmpty) ...[
                                                                    const SizedBox(height: 4),
                                                                    Text(
                                                                      shop.categories.join(', '),
                                                                      style: CommonStyle.bodySmall.copyWith(
                                                                        color: AppColors.textSecondary,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.chevron_right_rounded,
                                                              color: AppColors.textSecondary,
                                                              size: 24,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
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
    if (_stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No stores available',
              style: CommonStyle.heading4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new stores',
              style: CommonStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

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
          if (index >= _stores.length) {
            return const SizedBox.shrink();
          }
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
