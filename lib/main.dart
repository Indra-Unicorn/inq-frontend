import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'features/customer/models/shop.dart';
import 'features/customer/pages/store/store_details_page.dart';
import 'features/customer/pages/queue/queue_status_page.dart';
import 'features/merchant/merchant_profile.dart';
import 'features/merchant/queue_management.dart';
import 'features/merchant/models/merchant_queue.dart';
import 'services/notification_service.dart';

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
        print('Firebase already initialized, continuing...');
      } else {
        print('Firebase initialization error: $e');
        rethrow;
      }
    }

    print('Firebase initialized successfully');

    // Initialize notifications on all platforms
    await NotificationService.initialize();
  } catch (e) {
    print('Setup error: $e');
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
          seedColor: const Color(0xFFE9B8BA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/customer-signup': (context) => const CustomerSignUpPage(),
        '/merchant-signup': (context) => const MerchantSignUpPage(),
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/merchant-dashboard': (context) => const MerchantDashboard(),
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
        '/store-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Shop;
          return StoreDetailsPage(store: args);
        },
      },
      onGenerateRoute: (settings) {
        return null;
      },
    );
  }
}
