import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../shared/constants/app_constants.dart';
import 'login_page.dart';
import '../customer/pages/dashboard/customer_dashboard.dart';
import '../merchant/merchant_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Add a minimum delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Check if user is logged in
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // Get user type from stored data or JWT token
        final userType = await AuthService.getUserType();

        if (userType == null) {
          // Unknown user type, go to login
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }

        // Navigate based on user type
        if (mounted) {
          if (userType == AppConstants.userTypeCustomer) {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
          } else if (userType == AppConstants.userTypeMerchant) {
            Navigator.pushReplacementNamed(context, '/merchant-dashboard');
          } else {
            // Unknown user type, go to login
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        // Not logged in, go to login page
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error during auth check: $e');
      // On error, go to login page
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF305CDE),
                      Color(0xFF20B2AA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF305CDE).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.queue,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              const Text(
                'Queue Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D29),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Smart Queue Management System',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF305CDE)),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
