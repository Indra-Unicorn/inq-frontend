import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_page.dart';
import 'features/auth/customer_signup.dart';
import 'features/auth/merchant_signup.dart';
import 'features/customer/pages/dashboard/customer_dashboard.dart';
import 'features/customer/pages/profile/customer_profile_page.dart';
import 'features/merchant/merchant_dashboard.dart';
import 'features/customer/pages/queue/customer_queues.dart';
import 'features/merchant/store_profile_page.dart';
import 'features/customer/pages/store/store_details_page.dart';
import 'features/customer/pages/queue/queue_status_page.dart';
import 'features/merchant/merchant_profile.dart';
import 'features/merchant/queue_management.dart';
import 'features/merchant/models/merchant_queue.dart';
import 'features/merchant/controllers/merchant_dashboard_controller.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'shared/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized to prevent duplicate app error
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        // Firebase already initialized, continuing...
      } else {
        rethrow;
      }
    }

    // Initialize notifications on all platforms
    await NotificationService.initialize();
  } catch (e) {
    // Silently handle setup errors
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Queue Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF305CDE),
          secondary: const Color(0xFF20B2AA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF305CDE),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF305CDE), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFBFF),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/customer-signup': (context) => const CustomerSignUpPage(),
        '/merchant-signup': (context) => const MerchantSignUpPage(),
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/merchant-dashboard': (context) => ChangeNotifierProvider(
              create: (_) => MerchantDashboardController(),
              child: const MerchantDashboard(),
            ),
        '/customer-queues': (context) => const CustomerQueuesPage(),
        '/store-profile': (context) => const StoreProfilePage(),
        '/customer-profile': (context) => const CustomerProfilePage(),
        '/merchant-profile': (context) => const MerchantProfile(),
        '/queue-status': (context) => const QueueStatusPage(),
        '/queue-management': (context) {
          final queueData = ModalRoute.of(context)!.settings.arguments;
          MerchantQueue queue;

          if (queueData is MerchantQueue) {
            queue = queueData;
          } else if (queueData is Map<String, dynamic>) {
            queue = MerchantQueue.fromJson(queueData);
          } else {
            throw ArgumentError('Invalid queue data type');
          }

          return QueueManagement(queue: queue);
        },
      },
      onGenerateRoute: (settings) {
        // Handle store details with shop ID in URL
        if (settings.name?.startsWith('/store/') == true) {
          final shopId = settings.name!.substring('/store/'.length);
          return MaterialPageRoute(
            builder: (context) => StoreDetailsPage(shopId: shopId),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
