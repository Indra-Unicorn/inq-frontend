import 'package:flutter/material.dart';

class MerchantSignUpPage extends StatefulWidget {
  const MerchantSignUpPage({super.key});

  @override
  State<MerchantSignUpPage> createState() => _MerchantSignUpPageState();
}

class _MerchantSignUpPageState extends State<MerchantSignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
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
                      'Sign up',
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

                    // Utilize the _buildInputField method
                    _buildInputField(
                      controller: _fullNameController,
                      placeholder: 'Full name',
                    ),

                    _buildInputField(
                      controller: _emailController,
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Continue with the rest of your input fields
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: 'Password',
                      obscureText: true,
                    ),
                    
                    _buildInputField(
                      controller: _shopNameController,
                      placeholder: 'Shop name',
                    ),
                    
                    _buildInputField(
                      controller: _streetAddressController,
                      placeholder: 'Street address',
                    ),
                    
                    _buildInputField(
                      controller: _cityController,
                      placeholder: 'City',
                    ),
                    
                    _buildInputField(
                      controller: _countryController,
                      placeholder: 'Country',
                    ),
                    
                    _buildInputField(
                      controller: _stateController,
                      placeholder: 'State',
                    ),
                    
                    _buildInputField(
                      controller: _postalCodeController,
                      placeholder: 'Postal code',
                    ),

                    const SizedBox(height: 12),
                    
                    // Sign Up Button
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle merchant sign up logic
                          print('Merchant Sign Up');
                          print('Name: ${_fullNameController.text}');
                          print('Email: ${_emailController.text}');
                          print('Shop: ${_shopNameController.text}');
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
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.015,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Instructions and other links
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Log in',
                        style: TextStyle(
                          color: Color(0xFF82686A),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/customer-signup');
                      },
                      child: const Text(
                        'Sign up as a customer',
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