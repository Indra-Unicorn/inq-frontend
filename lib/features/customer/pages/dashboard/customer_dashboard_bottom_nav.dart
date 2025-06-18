import 'package:flutter/material.dart';

class CustomerDashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const CustomerDashboardBottomNav(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFF4F0F0),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF181111),
        unselectedItemColor: const Color(0xFF886364),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
