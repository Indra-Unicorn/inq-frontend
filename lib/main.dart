import 'package:flutter/material.dart';
import 'Common/login_page.dart';
import 'Customer/Screens/Auth/customer_signup.dart';
import 'merchant/merchant_signup.dart';
import 'Customer/Screens/dashboard/customer_dashboard.dart';
import 'merchant/merchant_dashboard.dart';
import 'Customer/Screens/customer_queues.dart';
import 'Common/store_profile_page.dart';
import 'Customer/Screens/Auth/customer_profile_page.dart';
import 'queue_status_page.dart';
import 'Common/store_details_page.dart';

void main() {
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
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => StoreDetailsPage(
              storeName: args?['storeName'] as String? ?? 'Store',
              storeAddress: args?['storeAddress'] as String? ?? 'Address',
              storeImage: args?['storeImage'] as String?,
              queues: args?['queues'] as List<Map<String, dynamic>>? ?? [],
            ),
          );
        }
        return null;
      },
    );
  }
}