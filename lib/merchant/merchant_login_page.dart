import 'package:flutter/material.dart';
import '../google_logo_painter.dart'; // Import custom painter if needed
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantLoginPage extends StatefulWidget {
  const MerchantLoginPage({super.key});

  @override
  State<MerchantLoginPage> createState() => _MerchantLoginPageState();
}

class _MerchantLoginPageState extends State<MerchantLoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/merchant'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': _phoneController.text,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Store the token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);

        Navigator.pushReplacementNamed(context, '/merchant-dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to login')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
                'Merchant Login',
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
                  _buildInputField(
                    controller: _phoneController,
                    placeholder: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 12),

                  // Continue with Phone Button
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9B8BA),
                        foregroundColor: const Color(0xFF191010),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue with Phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sign up link for Merchant
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/merchant-signup');
                    },
                    child: const Text(
                      'New user? Sign up as a Merchant',
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
          hintStyle: const TextStyle(color: Color(0xFF8B5B5C), fontSize: 16),
          filled: true,
          fillColor: const Color(0xFFFBF9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE3D4D4)),
          ),
        ),
        style: const TextStyle(color: Color(0xFF191010), fontSize: 16),
      ),
    );
  }
}
