import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerLoginPage extends StatefulWidget {
  const CustomerLoginPage({super.key});

  @override
  State<CustomerLoginPage> createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _sessionId;
  bool _isInitiated = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _initiateLogin() async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/api/auth/login/customer/initiate?phoneNumber=${_phoneController.text}'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      setState(() {
        _sessionId = data['data']['session_id'];
        _isInitiated = true;
      });
    } else {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to initiate login')),
      );
    }
  }

  Future<void> _verifyLogin() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/customer/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': _phoneController.text,
        'sessionId': _sessionId,
        'otp': _otpController.text,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      // Store the token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']);

      // Navigate to customer dashboard after successful login
      Navigator.pushReplacementNamed(context, '/customer-dashboard');
    } else {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to verify login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Customer Login',
                style: TextStyle(
                  color: Color(0xFF191010),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),

            // Phone Input Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Phone Number Input
                  _buildInputField(
                    controller: _phoneController,
                    placeholder: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),

                  if (_isInitiated) ...[
                    // OTP Input
                    _buildInputField(
                      controller: _otpController,
                      placeholder: 'Enter OTP',
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Continue with Phone Button
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isInitiated ? _verifyLogin : _initiateLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9B8BA),
                        foregroundColor: const Color(0xFF191010),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isInitiated ? 'Verify OTP' : 'Continue with Phone',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sign up link
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/customer-signup');
                    },
                    child: const Text(
                      'New user? Sign up as a Customer',
                      style: TextStyle(
                        color: Color(0xFF8B5B5C),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFF8B5B5C),
            fontSize: 16,
          ),
          filled: true,
          fillColor: const Color(0xFFFBF9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE3D4D4),
            ),
          ),
        ),
        style: const TextStyle(
          color: Color(0xFF191010),
          fontSize: 16,
        ),
      ),
    );
  }
}
