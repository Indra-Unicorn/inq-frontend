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

  // Routes that require a logged-in session to access
  static const _protectedRoutes = {
    '/merchant-dashboard',
    '/customer-profile',
    '/merchant-profile',
    '/store-profile',
    '/customer-queues',
    '/queue-status',
    '/queue-management',
    '/admin-dashboard',
  };

  Future<void> _checkAuthAndNavigate() async {
    try {
      // On web, skip the artificial delay — users shouldn't be stuck on the
      // loading screen every time they load or refresh the URL.
      // On mobile, keep a short delay so the splash animation is visible.
      if (!kIsWeb) {
        await Future.delayed(const Duration(seconds: 2));
      }

      final isLoggedIn = await AuthService.isLoggedIn();

      // On web, honour the current URL path when it is meaningful
      if (kIsWeb) {
        final currentRoute = _getCurrentWebRoute();

        if (currentRoute != null &&
            currentRoute != '/' &&
            currentRoute != '/splash' &&
            _isValidRoute(currentRoute)) {
          // If the target route needs auth and the user isn't logged in,
          // send them to login instead of the protected page.
          if (_protectedRoutes.contains(currentRoute) && !isLoggedIn) {
            final loginRoute = currentRoute == '/admin-dashboard'
                ? '/admin-login'
                : '/login';
            if (mounted) Navigator.pushReplacementNamed(context, loginRoute);
            return;
          }
          if (mounted) Navigator.pushReplacementNamed(context, currentRoute);
          return;
        }

        // Root URL → fall through to role-based logic below
      }

      if (isLoggedIn) {
        final userType = await AuthService.getUserType();

        final targetRoute = userType == AppConstants.userTypeCustomer
            ? '/customer-dashboard'
            : userType == AppConstants.userTypeMerchant
                ? '/merchant-dashboard'
                : userType == AppConstants.userTypeAdmin
                    ? '/admin-dashboard'
                    : '/customer-dashboard';

        if (mounted) Navigator.pushReplacementNamed(context, targetRoute);
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/customer-dashboard');
        }
      }
    } catch (e) {
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
    const knownRoutes = {
      '/login',
      '/customer-signup',
      '/merchant-signup',
      '/about-us',
      '/privacy-policy',
      '/customer-dashboard',
      '/merchant-dashboard',
      '/customer-queues',
      '/store-profile',
      '/customer-profile',
      '/merchant-profile',
      '/queue-status',
      '/queue-management',
      '/admin-login',
      '/admin-dashboard',
    };

    if (knownRoutes.contains(route)) return true;
    if (route.startsWith('/store/')) return true;
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
                  // App Logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF305CDE).withValues(alpha: 0.12),
                              const Color(0xFF305CDE).withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Icon — no background, just the logo on the gradient
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          'assets/app_icon/icon_without_background.png',
                          fit: BoxFit.contain,
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
