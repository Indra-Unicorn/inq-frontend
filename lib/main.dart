import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'customer_signup.dart';
import 'merchant_signup.dart';
import 'customer_dashboard.dart';
import 'merchant_dashboard.dart';
import 'customer_queues.dart';
import 'store_profile_page.dart';
import 'customer_profile_page.dart';
import 'store_details_page.dart';
import 'queue_status_page.dart';
import 'notification_service.dart';

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
      title: 'Queue Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE9B8BA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/customer-signup': (context) => const CustomerSignUpPage(),
        '/merchant-signup': (context) => const MerchantSignUpPage(),
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/merchant-dashboard': (context) => const MerchantDashboard(),
        '/customer-queues': (context) => const CustomerQueuesPage(),
        '/store-profile': (context) => const StoreProfilePage(),
        '/customer-profile': (context) => const CustomerProfilePage(),
        '/queue-status': (context) => const QueueStatusPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/store-details') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) => StoreDetailsPage(
              storeName: args?['storeName'] ?? 'Store',
              storeAddress: args?['storeAddress'] ?? 'Address',
              storeImage: args?['storeImage'] ?? 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=300&fit=crop',
            ),
          );
        }
        return null;
      },
    );
  }
}