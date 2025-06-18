import 'package:flutter/material.dart';

class CustomerDashboardCategories extends StatelessWidget {
  final List<String> categories;
  const CustomerDashboardCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              label: Text(
                categories[index],
                style: const TextStyle(
                  color: Color(0xFF181111),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFFF4F0F0),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
