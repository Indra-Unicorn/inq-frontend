import 'package:flutter/material.dart';

class CustomerSignUpPage extends StatefulWidget {
  const CustomerSignUpPage({super.key});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    
                    // Email
                    _buildInputField(
                      controller: _emailController,
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    // Phone
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    
                    // Password
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: 'Password',
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Sign Up Button
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Customer Sign Up');
                          print('Name: ${_fullNameController.text}');
                          print('Email: ${_emailController.text}');
                          print('Phone: ${_phoneController.text}');
                          // Navigate to customer dashboard after successful signup
                          Navigator.pushReplacementNamed(context, '/customer-dashboard');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8B4B7),
                          foregroundColor: const Color(0xFF171212),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
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
                        Navigator.pushReplacementNamed(context, '/merchant-signup');
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
          hintStyle: const TextStyle(
            color: Color(0xFF82686A),
            fontSize: 16,
          ),
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
        style: const TextStyle(
          color: Color(0xFF171212),
          fontSize: 16,
        ),
      ),
    );
  }
}