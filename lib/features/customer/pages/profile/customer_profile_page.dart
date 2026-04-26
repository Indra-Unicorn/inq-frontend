import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _showCustomAmountSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add inQoin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '1 inQoin = ₹1  ·  Minimum ₹1',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Amount input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 8, top: 14),
                        child: Text('₹',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                      prefixIconConstraints: const BoxConstraints(),
                      hintText: '0',
                      hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withOpacity(0.4)),
                      suffixText: 'inQoin',
                      suffixStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick pick chips
                Wrap(
                  spacing: 8,
                  children: [15, 25, 50, 100].map((v) {
                    return GestureDetector(
                      onTap: () => controller.text = v.toString(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          '₹$v',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final raw = int.tryParse(controller.text.trim());
                      if (raw == null || raw < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid amount (min ₹1)')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      _openCheckout(raw, raw);
                    },
                    child: Text(
                      'Proceed to Pay',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero header with avatar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ProfileHeader(
                      onBackPressed: () => Navigator.pop(context),
                      name: _userData?['name'],
                      email: _userData?['email'],
                      phoneNumber: _userData?['phoneNumber'],
                      profileImage: _userData?['profileImage'],
                      onEditAvatar: () {
                        // TODO: Implement profile image update
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Name & identity
                        Text(
                          _userData?['name'] ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?['phoneNumber'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_userData?['email'] != null &&
                            _userData!['email'].toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _userData!['email'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(child: _buildStatsRow()),

                // inQoin Wallet card
                SliverToBoxAdapter(child: _buildWalletCard()),

                // Personal info card
                SliverToBoxAdapter(child: _buildPersonalInfoCard()),

                // More section
                SliverToBoxAdapter(child: _buildMoreSection()),

                // Logout row
                SliverToBoxAdapter(child: _buildLogoutRow()),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  // ─── Stats ──────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Row(
        children: [
          _StatPill(
            value: (_userData?['inQoin'] ?? 0).toString(),
            label: 'inQoin',
            icon: Icons.monetization_on_rounded,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          _StatPill(
            value: (_userData?['pastQueuesJoined'] ?? 0).toString(),
            label: 'Queues',
            icon: Icons.people_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _StatPill(
            value: _formatTimeSaved(
                (_userData?['timeSaved'] as num?)?.toInt() ?? 0),
            label: 'Time Saved',
            icon: Icons.timer_rounded,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  // ─── Wallet ──────────────────────────────────────────────────────────────────

  Widget _buildWalletCard() {
    final balance = (_userData?['inQoin'] ?? 0).toString();
    final isDisabled = _isProcessingPayment || _userData == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF305CDE), Color(0xFF1E3FA3)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'inQoin Wallet',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'coins',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick top-up options
            Row(
              children: [
                Expanded(
                    child: _TopUpButton(
                        amount: 5,
                        coins: 5,
                        isLoading: _isProcessingPayment,
                        disabled: isDisabled,
                        onTap: () => _openCheckout(5, 5))),
                const SizedBox(width: 10),
                Expanded(
                    child: _TopUpButton(
                        amount: 10,
                        coins: 10,
                        isLoading: _isProcessingPayment,
                        disabled: isDisabled,
                        onTap: () => _openCheckout(10, 10))),
                const SizedBox(width: 10),
                Expanded(
                    child: _TopUpButton(
                        amount: 20,
                        coins: 20,
                        isLoading: _isProcessingPayment,
                        disabled: isDisabled,
                        onTap: () => _openCheckout(20, 20))),
              ],
            ),
            const SizedBox(height: 12),
            // Custom amount button
            GestureDetector(
              onTap: isDisabled ? null : _showCustomAmountSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.9), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Enter custom amount',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
  }

  // ─── Personal Info ───────────────────────────────────────────────────────────

  Widget _buildPersonalInfoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: _SectionCard(
        title: 'Personal Information',
        icon: Icons.person_outline_rounded,
        iconColor: AppColors.primary,
        trailing: _isEditing
            ? null
            : GestureDetector(
                onTap: () => setState(() => _isEditing = true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
        child: Column(
          children: [
            _buildModernField(
              label: 'Full Name',
              controller: _nameController,
              enabled: _isEditing,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            _buildModernField(
              label: 'Email Address',
              controller: _emailController,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              hintText:
                  _userData?['email'] == null ? 'No email provided' : null,
            ),
            const SizedBox(height: 12),
            _buildModernField(
              label: 'Phone Number',
              controller: TextEditingController(
                  text: _userData?['phoneNumber'] ?? ''),
              enabled: false,
              icon: Icons.phone_outlined,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => setState(() {
                                _isEditing = false;
                                _nameController.text =
                                    _userData?['name'] ?? '';
                                _emailController.text =
                                    _userData?['email'] ?? '';
                              }),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                            color: AppColors.border.withOpacity(0.8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── More / Settings ─────────────────────────────────────────────────────────

  Widget _buildMoreSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: _SectionCard(
        title: 'More',
        icon: Icons.grid_view_rounded,
        iconColor: AppColors.warning,
        child: Column(
          children: [
            _buildSettingItem(
              'Privacy & Security',
              'Manage your privacy settings',
              Icons.shield_outlined,
              AppColors.info,
              () => Navigator.pushNamed(context, '/privacy-policy'),
            ),
            _Divider(),
            _buildSettingItem(
              'Help & Support',
              'Contact our support team',
              Icons.headset_mic_outlined,
              AppColors.success,
              _launchSupportEmail,
            ),
            _Divider(),
            _buildSettingItem(
              'About',
              'Learn more about inQueue',
              Icons.info_outline_rounded,
              AppColors.primary,
              () => Navigator.pushNamed(context, '/about-us'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: InkWell(
        onTap: _showLogoutDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.error.withOpacity(0.15), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 18),
              ),
              const SizedBox(width: 14),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.error.withOpacity(0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard() => const SizedBox.shrink();

  static const String _supportEmail = 'team@inqueue.in';

  Future<void> _launchSupportEmail() async {
    try {
      if (kIsWeb) {
        final gmailUrl = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&to=$_supportEmail&su=${Uri.encodeQueryComponent('inQueue Support Request')}&body=${Uri.encodeQueryComponent('Hello inQueue Support Team,\n\n')}',
        );
        if (await canLaunchUrl(gmailUrl)) {
          await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        final emailUri = Uri(
          scheme: 'mailto',
          path: _supportEmail,
          queryParameters: {
            'subject': 'inQueue Support Request',
            'body': 'Hello inQueue Support Team,\n\n',
          },
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          return;
        }
      }
      _showSupportEmailFallback();
    } catch (_) {
      _showSupportEmailFallback();
    }
  }

  void _showSupportEmailFallback() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open mail app. Email us at $_supportEmail'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() => const SizedBox.shrink();

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
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border.withOpacity(0.4),
        ),
        color: enabled ? Colors.white : const Color(0xFFF5F7FA),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(icon,
                  color: enabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          labelStyle: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Private helper widgets ──────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatPill(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUpButton extends StatelessWidget {
  final int amount;
  final int coins;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _TopUpButton(
      {required this.amount,
      required this.coins,
      required this.isLoading,
      required this.disabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              )
            : Column(
                children: [
                  Text('₹$amount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text('$coins coins',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.border.withOpacity(0.5),
      height: 1,
      thickness: 1,
    );
  }
}
