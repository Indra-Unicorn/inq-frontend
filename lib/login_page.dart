import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard functionality
import 'google_logo_painter.dart'; // Import custom painter if needed
import 'notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController(); // Add token controller
  String? _fcmToken; // Store the FCM token

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _tokenController.dispose(); // Dispose token controller
    super.dispose();
  }

  // Method to get and display FCM token
  Future<void> _getFCMToken() async {
    try {
      String? token = await NotificationService.getToken();
      setState(() {
        _fcmToken = token;
        _tokenController.text = token ?? 'No token received';
      });
      print('FCM Token: $token');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FCM Token retrieved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting FCM token: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Method to copy token to clipboard
  void _copyTokenToClipboard() {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
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
            // FCM Token Testing Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E9EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3D4D4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FCM Token Testing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191010),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Token display text field
                  TextField(
                    controller: _tokenController,
                    readOnly: true,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'FCM Token will appear here...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8B5B5C),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFE3D4D4),
                        ),
                      ),
                      suffixIcon: _fcmToken != null
                          ? IconButton(
                              icon: Icon(Icons.copy, color: Color(0xFF8B5B5C)),
                              onPressed: _copyTokenToClipboard,
                              tooltip: 'Copy token',
                            )
                          : null,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF191010),
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getFCMToken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE9B8BA),
                            foregroundColor: const Color(0xFF191010),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Get FCM Token',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await NotificationService.showTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Test notification sent')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1E9EA),
                            foregroundColor: const Color(0xFF191010),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Test Notification',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
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