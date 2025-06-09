import 'package:flutter/material.dart';
import 'google_logo_painter.dart'; // Import custom painter if needed
import 'fcm_token_page.dart'; // Import the new FCM token page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                'Queue Management',
                style: TextStyle(
                  color: Color(0xFF191010),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ),
            
            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE3D4D4),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFE9B8BA),
                indicatorWeight: 3,
                labelColor: const Color(0xFF191010),
                unselectedLabelColor: const Color(0xFF8B5B5C),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.015,
                ),
                tabs: const [
                  Tab(text: 'Customer'),
                  Tab(text: 'Merchant'),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomerTab(),
                  _buildMerchantTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTab() {
    return Column(
      children: [
        const Spacer(),
        
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
              
              const SizedBox(height: 12),
              
              // Continue with Phone Button
              Container(
                constraints: const BoxConstraints(maxWidth: 480),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle phone login - navigate to customer dashboard
                    print('Continue with phone: ${_phoneController.text}');
                    Navigator.pushReplacementNamed(context, '/customer-dashboard');
                  },
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
              // Button to navigate to the FCM Token Page
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const FCMTokenPage())
                  );
                },
                child: const Text('Go to FCM Token Page'),
              ),
            ),
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
        
        const Spacer(),
        
        // Continue with Google Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle Google login - navigate to customer dashboard
                print('Continue with Google');
                Navigator.pushReplacementNamed(context, '/customer-dashboard');
              },
              icon: Container(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: GoogleLogoPainter(),
                ),
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.015,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1E9EA),
                foregroundColor: const Color(0xFF191010),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMerchantTab() {
    return Column(
      children: [
        const Spacer(),
        
        // Phone Input Section for Merchant
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
                  onPressed: () {
                    // Handle merchant phone login - navigate to merchant dashboard
                    print('Merchant login with phone: ${_phoneController.text}');
                    Navigator.pushReplacementNamed(context, '/merchant-dashboard');
                  },
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
        
        const Spacer(),
        
        // Continue with Google Button for Merchant
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle Google login for merchant - navigate to merchant dashboard
                print('Merchant login with Google');
                Navigator.pushReplacementNamed(context, '/merchant-dashboard');
              },
              icon: Container(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: GoogleLogoPainter(),
                ),
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.015,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1E9EA),
                foregroundColor: const Color(0xFF191010),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
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