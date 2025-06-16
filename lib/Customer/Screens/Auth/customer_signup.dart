import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';

class CustomerSignUpPage extends StatefulWidget {
  const CustomerSignUpPage({super.key});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _sessionId;
  bool _isInitiated = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _initiateSignup() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/customer/phone/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _fullNameController.text,
        'phoneNumber': _phoneController.text,
      }),
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
        SnackBar(content: Text(data['message'] ?? 'Failed to initiate signup')),
      );
    }
  }

  Future<void> _verifySignup() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup/customer/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _fullNameController.text,
        'sessionId': _sessionId,
        'phone': _phoneController.text,
        'otp': _otpController.text,
      }),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      // Navigate to customer dashboard after successful signup
      Navigator.pushReplacementNamed(context, '/customer-dashboard');
    } else {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to verify signup')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF171212),
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF171212),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Full Name
                    _buildInputField(
                      controller: _fullNameController,
                      placeholder: 'Full Name',
                    ),

                    // Phone
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),

                    if (_isInitiated) ...[
                      // OTP
                      _buildInputField(
                        controller: _otpController,
                        placeholder: 'Enter OTP',
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Sign Up Button
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isInitiated
                            ? _verifySignup
                            : _initiateSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8B4B7),
                          foregroundColor: const Color(0xFF171212),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isInitiated ? 'Verify OTP' : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.015,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login link
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          color: Color(0xFF82686A),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Merchant signup link
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/merchant-signup',
                        );
                      },
                      child: const Text(
                        'Are you a merchant? Sign Up',
                        style: TextStyle(
                          color: Color(0xFF82686A),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
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
          hintStyle: const TextStyle(color: Color(0xFF82686A), fontSize: 16),
          filled: true,
          fillColor: const Color(0xFFF4F1F1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(color: Color(0xFF171212), fontSize: 16),
      ),
    );
  }
}
