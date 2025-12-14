import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../shared/constants/app_constants.dart';

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

      // On web, check if we should preserve the current route
      if (kIsWeb) {
        // Get route from URL
        final currentRoute = _getCurrentWebRoute();
        
        // If we're on a valid route (not splash or root), preserve it
        if (currentRoute != null && 
            currentRoute != '/' && 
            currentRoute != '/splash' &&
            _isValidRoute(currentRoute)) {
          // Navigate to the current route to preserve it
          if (mounted) {
            Navigator.pushReplacementNamed(context, currentRoute);
          }
          return;
        }
        
        // If route is root (/), navigate to dashboard
        if (currentRoute == '/') {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
          }
          return;
        }
      }

      if (isLoggedIn) {
        // Get user type from stored data or JWT token
        final userType = await AuthService.getUserType();

        if (userType == null) {
          // Unknown user type, go to customer dashboard (public access)
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/customer-dashboard');
          }
          return;
        }

        // Navigate based on user type
        if (mounted) {
          final targetRoute = userType == AppConstants.userTypeCustomer
              ? '/customer-dashboard'
              : userType == AppConstants.userTypeMerchant
                  ? '/merchant-dashboard'
                  : '/customer-dashboard';
          
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      } else {
        // Not logged in, go to customer dashboard (public access)
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/customer-dashboard');
        }
      }
    } catch (e) {
      // On error, go to customer dashboard (public access)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/customer-dashboard');
      }
    }
  }

  // Get current route from web URL
  String? _getCurrentWebRoute() {
    if (!kIsWeb) return null;
    
    try {
      final uri = Uri.base;
      
      // Flutter web uses hash-based routing by default
      // The route is in the fragment (e.g., #/store/123 -> /store/123)
      String? route;
      
      if (uri.fragment.isNotEmpty) {
        // Fragment contains the route, remove leading # if present
        route = uri.fragment.startsWith('#') 
            ? uri.fragment.substring(1) 
            : uri.fragment;
        
        // Ensure it starts with /
        if (!route.startsWith('/')) {
          route = '/$route';
        }
      } else if (uri.path.isNotEmpty && uri.path != '/') {
        // Fallback to path if fragment is empty (for non-hash routing)
        route = uri.path;
      } else {
        route = '/';
      }
      
      return route;
    } catch (e) {
      return null;
    }
  }

  // Check if the route is valid (exists in our routes or is a dynamic route)
  bool _isValidRoute(String route) {
    // List of known routes
    const knownRoutes = [
      '/login',
      '/customer-signup',
      '/merchant-signup',
      '/customer-dashboard',
      '/merchant-dashboard',
      '/customer-queues',
      '/store-profile',
      '/customer-profile',
      '/merchant-profile',
      '/queue-status',
      '/queue-management',
    ];
    
    // Check if it's a known route
    if (knownRoutes.contains(route)) {
      return true;
    }
    
    // Check if it's a dynamic route (e.g., /store/{shopId})
    if (route.startsWith('/store/')) {
      return true;
    }
    
    return false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFBFF),
              Color(0xFFF0F4FF),
              Color(0xFFE8F0FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced App Logo with multiple layers
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow effect
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF305CDE).withValues(alpha: 0.1),
                              const Color(0xFF305CDE).withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Main logo container
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF305CDE),
                              Color(0xFF4F75FF),
                              Color(0xFF20B2AA),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF305CDE).withValues(alpha: 0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFF305CDE).withValues(alpha: 0.2),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background pattern
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Main icon with enhanced design
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Queue lines background
                                  Positioned(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 50,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 35,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Main queue icon
                                  const Icon(
                                    Icons.people_outline,
                                    size: 65,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Enhanced App Name with gradient text effect
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF305CDE),
                        Color(0xFF4F75FF),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'INQ',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Queue Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D29),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Enhanced Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF305CDE).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF305CDE).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Smart • Fast • Efficient',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF305CDE),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Enhanced Loading indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF305CDE).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      // Inner ring
                      const SizedBox(
                        width: 35,
                        height: 35,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF305CDE)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Loading text
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
