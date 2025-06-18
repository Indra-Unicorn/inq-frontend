import 'package:flutter/material.dart';

class CustomerDashboardHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const CustomerDashboardHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Find a Store',
              style: TextStyle(
                color: Color(0xFF181111),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.015,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onProfileTap,
              icon: const Icon(
                Icons.person_outline,
                color: Color(0xFF181111),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
