import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'dart:async';
import '../../shared/constants/api_endpoints.dart';
import '../../shared/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../admin/pages/admin_login_page.dart';

class MerchantLogin extends StatefulWidget {
  const MerchantLogin({super.key});

  @override
  State<MerchantLogin> createState() => _MerchantLoginState();
}

class _MerchantLoginState extends State<MerchantLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Hidden admin access mechanism
  int _loginButtonClickCount = 0;
  DateTime? _firstClickTime;
  Timer? _clickResetTimer;

  @override
  void initState() {
    super.initState();
    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final route = await AuthService.dashboardRouteForCurrentUser();
    if (!mounted || route == null) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _clickResetTimer?.cancel();
    super.dispose();
  }

  void _handleLoginButtonClick() {
    final now = DateTime.now();
    
    // Reset if more than 5 seconds have passed since first click
    if (_firstClickTime != null) {
      final timeDifference = now.difference(_firstClickTime!);
      if (timeDifference.inSeconds >= 5) {
        _loginButtonClickCount = 0;
        _firstClickTime = null;
        _clickResetTimer?.cancel();
      }
    }
    
    // Set first click time if this is the first click
    if (_firstClickTime == null) {
      _firstClickTime = now;
      
      // Set timer to reset after 5 seconds
      _clickResetTimer?.cancel();
      _clickResetTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _loginButtonClickCount = 0;
            _firstClickTime = null;
          });
        }
      });
    }
    
    // Increment click count
    _loginButtonClickCount++;
    
    // Check if 5 clicks happened within 5 seconds
    if (_loginButtonClickCount >= 5) {
      _clickResetTimer?.cancel();
      _loginButtonClickCount = 0;
      _firstClickTime = null;
      
      // Navigate to admin login page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminLoginPage(),
        ),
      );
      return;
    }
    
    // Proceed with normal login only if not triggering admin access
    _handleLogin();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.merchantLogin}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        final userData = {
          'userType': data['data']['userType'],
          'memberId': data['data']['id'],
          'email': data['data']['email'],
          'name': data['data']['name'],
          'phoneNumber': data['data']['phoneNumber'],
          'status': data['data']['status'],
        };
        final refreshToken = data['data']['refreshToken'];

        // Store token and user data using AuthService
        await AuthService.storeAuthData(
          token: token,
          userData: userData,
          refreshToken: refreshToken,
        );


        // Register FCM token (only on mobile platforms)
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          await _registerFCMToken(token);
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/merchant-dashboard', (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerFCMToken(String jwtToken) async {
    try {
      final decodedToken = JwtDecoder.decode(jwtToken);
      final userId = decodedToken['memberId'];
      final userType = decodedToken['userType'];

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
      final deviceModel = Platform.operatingSystemVersion;
      final appVersion = '1.0.0';
      final osVersion = Platform.operatingSystemVersion;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.registerFCMToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'userId': userId,
          'userType': userType,
          'fcmToken': fcmToken,
          'deviceType': deviceType,
          'deviceModel': deviceModel,
          'appVersion': appVersion,
          'osVersion': osVersion,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Merchant Sign In',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your details to manage your queue',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Login Form for Merchant
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            hintText: 'merchant@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLoginButtonClick,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),

          const SizedBox(height: 32),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New user? ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/merchant-signup');
                },
                child: Text(
                  'Sign up as a Merchant',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontSize: 15,
          ),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
