import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../services/admin_merchant_service.dart';
import '../../merchant/models/merchant_data.dart';
import 'admin_merchant_detail_page.dart';
import 'generate_merchant_qr_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _userData;
  List<MerchantData> _merchants = [];
  bool _isLoading = false;
  String _selectedStatus = 'CREATED';
  String? _errorMessage;

  final List<String> _statusOptions = ['CREATED', 'APPROVED', 'BLOCKED'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMerchants();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  Future<void> _loadMerchants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final merchants = await AdminMerchantService.getAllMerchants(_selectedStatus);
      setState(() {
        _merchants = merchants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMerchantStatus(String merchantId, String newStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await AdminMerchantService.updateMerchantStatus(merchantId, newStatus);
      
      // Reload merchants after status update
      await _loadMerchants();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merchant status updated to $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleStatusChange(String? newStatus) {
    if (newStatus != null && newStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = newStatus;
      });
      _loadMerchants();
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.clearAuthData();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  int _getTotalProcessed(MerchantData merchant) {
    int total = 0;
    for (var shop in merchant.shops) {
      for (var queue in shop.queueResponses) {
        total += queue.processed;
      }
    }
    return total;
  }

  int _getTotalSize(MerchantData merchant) {
    int total = 0;
    for (var shop in merchant.shops) {
      for (var queue in shop.queueResponses) {
        total += queue.size;
      }
    }
    return total;
  }

  String _getShopNames(MerchantData merchant) {
    if (merchant.shops.isEmpty) return 'No shops';
    return merchant.shops.map((shop) => shop.shopName).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenerateMerchantQRPage()),
              );
            },
            tooltip: 'Generate QR',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Dropdown
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.backgroundLight,
            child: Row(
              children: [
                Text(
                  'Filter by Status:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: _handleStatusChange,
                  ),
                ),
              ],
            ),
          ),

          // Merchants List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMerchants,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _merchants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No merchants found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMerchants,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _merchants.length,
                              itemBuilder: (context, index) {
                                return _MerchantCard(
                                  merchant: _merchants[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminMerchantDetailPage(
                                          merchant: _merchants[index],
                                        ),
                                      ),
                                    );
                                  },
                                  onActionTap: (merchant) {
                                    String newStatus;
                                    if (merchant.status == 'CREATED') {
                                      newStatus = 'APPROVED';
                                    } else if (merchant.status == 'APPROVED') {
                                      newStatus = 'BLOCKED';
                                    } else if (merchant.status == 'BLOCKED') {
                                      newStatus = 'APPROVED';
                                    } else {
                                      return;
                                    }
                                    _updateMerchantStatus(
                                      merchant.merchantId,
                                      newStatus,
                                    );
                                  },
                                  getTotalProcessed: _getTotalProcessed,
                                  getTotalSize: _getTotalSize,
                                  getShopNames: _getShopNames,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final MerchantData merchant;
  final VoidCallback onTap;
  final Function(MerchantData) onActionTap;
  final Function(MerchantData) getTotalProcessed;
  final Function(MerchantData) getTotalSize;
  final Function(MerchantData) getShopNames;

  const _MerchantCard({
    required this.merchant,
    required this.onTap,
    required this.onActionTap,
    required this.getTotalProcessed,
    required this.getTotalSize,
    required this.getShopNames,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREATED':
        return AppColors.info;
      case 'APPROVED':
        return AppColors.success;
      case 'BLOCKED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getActionButtonText(String status) {
    switch (status) {
      case 'CREATED':
        return 'Approve';
      case 'APPROVED':
        return 'Block';
      case 'BLOCKED':
        return 'Approve';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalProcessed = getTotalProcessed(merchant);
    final totalSize = getTotalSize(merchant);
    final shopNames = getShopNames(merchant);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(merchant.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(merchant.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      merchant.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(merchant.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.store,
                      label: 'Shop',
                      value: shopNames,
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.monetization_on,
                      label: 'inQoin',
                      value: merchant.inQoin.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.people,
                      label: 'Processed',
                      value: totalProcessed.toString(),
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.queue,
                      label: 'Queue Size',
                      value: totalSize.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Button
              if (merchant.status == 'CREATED' || merchant.status == 'APPROVED' || merchant.status == 'BLOCKED')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onActionTap(merchant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: merchant.status == 'CREATED' || merchant.status == 'BLOCKED'
                          ? AppColors.success
                          : AppColors.error,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getActionButtonText(merchant.status),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
