import 'package:flutter/material.dart';
import '../Customer/Screens/Auth/customer_login_page.dart';
import '../merchant/merchant_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCustomer = true;

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
                'Welcome Back',
                style: TextStyle(
                  color: Color(0xFF191010),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            
            // Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCustomer = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCustomer ? const Color(0xFFE9B8BA) : Colors.white,
                        foregroundColor: const Color(0xFF191010),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Customer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCustomer = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isCustomer ? const Color(0xFFE9B8BA) : Colors.white,
                        foregroundColor: const Color(0xFF191010),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Merchant'),
                    ),
                  ),
                ],
              ),
            ),
            
            // Login Form
            Expanded(
              child: _isCustomer
                  ? const CustomerLoginPage()
                  : const MerchantLoginPage(),
            ),
          ],
        ),
      ),
    );
  }
}