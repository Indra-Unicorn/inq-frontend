import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/profile_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/logout_dialog.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/api_endpoints.dart';
import '../../../../services/auth_service.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;
  final ProfileService _profileService = ProfileService();
  late Razorpay _razorpay;
  String? _currentOrderRef;
  bool _isProcessingPayment = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    debugPrint('CustomerProfilePage initState called');
    _razorpay = Razorpay();
    debugPrint('Razorpay instance created: $_razorpay');
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    debugPrint('Razorpay event handlers registered');
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _profileService.getUserData();
      setState(() {
        _userData = userData;
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final email = _emailController.text.trim();
      await _profileService.updateCustomerProfile(
        name: _nameController.text.trim(),
        email: email.isEmpty ? null : email,
      );
      setState(() {
        _isEditing = false;
        _userData?['name'] = _nameController.text.trim();
        _userData?['email'] = _emailController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutDialog(
          onLogout: () async {
            try {
              await _profileService.logout();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            }
          },
        );
      },
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment successful: ${response.paymentId}, order: ${response.orderId}');
    try {
      // Verify payment on backend
      final verificationResponse = await _verifyPayment(
        response.paymentId!,
        response.orderId!,
        response.signature!,
      );

      debugPrint('Verification response: $verificationResponse');

      if (verificationResponse != null && verificationResponse['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful! inQoin balance updated.')),
          );
        }
        // Refresh user data to show updated balance
        await _loadUserData();
        debugPrint('User data refreshed after successful payment');
      } else {
        final errorMessage = verificationResponse?['message'] ?? 'Unknown error';
        debugPrint('Payment verification failed: $errorMessage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment verification failed: $errorMessage')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verification failed. Please contact support.')),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _verifyPayment(String paymentId, String orderId, String signature) async {
    final token = await AuthService.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.verifyPayment}'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'razorpayPaymentId': paymentId,
        'razorpayOrderId': orderId,
        'razorpaySignature': signature,
        'orderRef': _currentOrderRef ?? ''
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    }
    return null;
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    debugPrint('Payment failed: ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
    // Reset loading state
    setState(() {
      _isProcessingPayment = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    debugPrint('External wallet selected: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
    // Reset loading state
    setState(() {
      _isProcessingPayment = false;
    });
  }

  Future<void> _openCheckout(int amount, int inQoinAmount) async {
    debugPrint('Starting payment checkout for amount: $amount, inQoin: $inQoinAmount');

    // Check if user data is loaded
    if (_userData == null) {
      debugPrint('User data not loaded yet');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait, loading user data...')),
        );
      }
      return;
    }

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      debugPrint('User is not logged in');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to make payments')),
        );
      }
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // First create order on backend
      final orderResponse = await _createPaymentOrder(amount, inQoinAmount);
      debugPrint('Order response: $orderResponse');

      if (orderResponse == null) {
        debugPrint('Order response is null, returning early');
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });
        }
        return;
      }

      final orderId = orderResponse['data']['razorpayOrderId'];
      final orderRef = orderResponse['data']['orderRef'];
      final razorpayKey = orderResponse['data']['key'];

      if (orderId == null || orderRef == null || razorpayKey == null) {
        debugPrint('Missing orderId, orderRef, or key in response');
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid order response from server')),
          );
        }
        return;
      }

      debugPrint('Order ID: $orderId, Order Ref: $orderRef, Key: $razorpayKey');

      // Check platform compatibility
      debugPrint('Platform check:');
      debugPrint('- isWeb: ${kIsWeb}');

      if (kIsWeb) {
        debugPrint('ERROR: Razorpay does not support web platform!');
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payments are not supported on web. Please use mobile app.')),
          );
        }
        return;
      }

      // Only check platform-specific properties after confirming not web
      debugPrint('- Platform.isAndroid: ${Platform.isAndroid}');
      debugPrint('- Platform.isIOS: ${Platform.isIOS}');

      var options = {
        'key': razorpayKey, // Use key from backend response
        'amount': amount * 100, // amount in paise
        'name': 'inQoin Purchase',
        'description': 'Buy $inQoinAmount inQoin',
        'order_id': orderId,
        'prefill': {
          'contact': _userData?['phone'] ?? '8888888888',
          'email': _userData?['email'] ?? 'test@example.com'
        },
        'theme': {
          'color': '#3399cc'
        }
      };

      debugPrint('Opening Razorpay with options: $options');
      debugPrint('Options validation:');
      debugPrint('- key: ${options['key'] != null ? "present (${options['key'].length} chars)" : "null"}');
      debugPrint('- amount: ${options['amount']}');
      debugPrint('- order_id: ${options['order_id'] != null ? "present (${options['order_id'].length} chars)" : "null"}');

      try {
        debugPrint('About to call _razorpay.open()...');
        _razorpay!.open(options);
        debugPrint('Razorpay.open() called successfully - payment page should open now');
      } catch (razorpayError) {
        debugPrint('CRITICAL ERROR: Razorpay.open() threw exception: $razorpayError');
        debugPrint('Exception type: ${razorpayError.runtimeType}');
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open payment gateway: $razorpayError')),
          );
        }
        return;
      }

      // Reset loading state after opening Razorpay
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate payment: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _createPaymentOrder(int amount, int inQoinAmount) async {
    final token = await AuthService.getToken();
    if (token == null) {
      debugPrint('No auth token found');
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
      }
      return null;
    }

    debugPrint('Auth token exists, length: ${token.length}');

    // Get customer ID from JWT token
    final decodedToken = JwtDecoder.decode(token);
    final customerId = decodedToken['memberId'];
    debugPrint('Decoded token memberId: $customerId');
    debugPrint('Full decoded token: $decodedToken');

    _currentOrderRef = 'INQOIN_${DateTime.now().millisecondsSinceEpoch}';

    debugPrint('Creating payment order with customerId: $customerId, amount: $amount');
    debugPrint('API URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.createPaymentOrder}');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.createPaymentOrder}'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'currency': 'INR',
        'customerId': customerId,
        'orderRef': _currentOrderRef
      }),
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      debugPrint('API request timed out');
      throw Exception('Request timeout');
    });

    debugPrint('Request body: ${jsonEncode({
      'amount': amount,
      'currency': 'INR',
      'customerId': customerId,
      'orderRef': _currentOrderRef
    })}');

    debugPrint('Payment order API response status: ${response.statusCode}');
    debugPrint('Payment order API response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Payment order created successfully: $data');
      return data;
    } else {
      debugPrint('Payment order API failed with status ${response.statusCode}');
      debugPrint('Error response: ${response.body}');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create payment order')),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ProfileHeader(
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Profile Avatar Section
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: _buildProfileAvatar(),
                        ),
                        
                        // Profile Stats Cards
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _buildStatsCards(),
                        ),
                        
                        // Buy inQoin Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _buildBuyInQoinCard(),
                        ),
                        
                        // Personal Information Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _buildPersonalInfoCard(),
                        ),
                        
                        // Account Settings Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _buildAccountSettingsCard(),
                        ),
                        
                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          child: _buildLogoutButton(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow effect
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Main avatar container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _userData?['profileImage'] != null &&
                          _userData!['profileImage'].toString().isNotEmpty
                      ? NetworkImage(_userData!['profileImage'])
                      : null,
                  child: _userData?['profileImage'] == null ||
                          _userData!['profileImage'].toString().isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              // Edit button
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Implement profile image update
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['name'] ?? 'User Name',
            style: CommonStyle.heading3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData?['email'] ?? 'No email provided',
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'inQoin Balance',
            (_userData?['inQoin'] ?? 0).toString(),
            Icons.monetization_on,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Queues Joined',
            (_userData?['pastQueuesJoined'] ?? 0).toString(),
            Icons.queue,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Saved Time',
            _formatTimeSaved((_userData?['timeSaved'] as num?)?.toInt() ?? 0),
            Icons.access_time,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: CommonStyle.heading4.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: CommonStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBuyInQoinCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_shopping_cart,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Buy inQoin',
                style: CommonStyle.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Purchase inQoin to join queues faster',
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInQoinOption(5, 5, '5 inQoin'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInQoinOption(10, 10, '10 inQoin'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInQoinOption(int amount, int inQoinAmount, String title) {
    final isDisabled = _isProcessingPayment || _userData == null;
    return InkWell(
      onTap: isDisabled ? null : () => _openCheckout(amount, inQoinAmount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.primary.withValues(alpha: 0.02)
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            if (_isProcessingPayment)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              )
            else
              Text(
                '₹$amount',
                style: CommonStyle.heading4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDisabled ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
            const SizedBox(height: 8),
            Icon(
              Icons.monetization_on,
              color: isDisabled ? AppColors.textSecondary : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: CommonStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Personal Information',
                  style: CommonStyle.heading4.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildModernField(
            label: 'Full Name',
            controller: _nameController,
            enabled: _isEditing,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildModernField(
            label: 'Email Address',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            hintText: _userData?['email'] == null ? 'No email provided' : null,
          ),
          const SizedBox(height: 16),
          _buildModernField(
            label: 'Phone Number',
            controller: TextEditingController(text: _userData?['phoneNumber'] ?? ''),
            enabled: false,
            icon: Icons.phone_outlined,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _isEditing = false;
                              _nameController.text = _userData?['name'] ?? '';
                              _emailController.text = _userData?['email'] ?? '';
                            });
                          },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Account Settings',
                style: CommonStyle.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            'Notifications',
            'Manage your notification preferences',
            Icons.notifications_outlined,
            () {
              // TODO: Navigate to notifications settings
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            'Privacy & Security',
            'Control your privacy settings',
            Icons.security_outlined,
            () {
              // TODO: Navigate to privacy settings
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            'Help & Support',
            'Get help and contact support',
            Icons.help_outline,
            () {
              // TODO: Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CommonStyle.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CommonStyle.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String _formatTimeSaved(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled 
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.3),
        ),
        color: enabled ? Colors.white : AppColors.background,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: CommonStyle.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null 
              ? Icon(
                  icon,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: CommonStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
