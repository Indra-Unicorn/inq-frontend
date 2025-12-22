import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import '../../../shared/constants/api_endpoints.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jwt_decoder/jwt_decoder.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
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
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.adminLogin}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': _identifierController.text,
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
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
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
        // Handle error silently
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Admin Login Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access admin panel',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildInputField(
                    controller: _identifierController,
                    label: 'Identifier',
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 12),

                  _buildInputField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textSecondary,
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
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.015,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back to login page
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}

