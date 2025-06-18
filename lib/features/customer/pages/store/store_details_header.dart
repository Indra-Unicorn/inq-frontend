import 'package:flutter/material.dart';
import '../../../../shared/common_style.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../models/shop.dart';

class StoreDetailsHeader extends StatelessWidget {
  final Shop store;

  const StoreDetailsHeader({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Store Image
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.network(
            store.images.isNotEmpty
                ? store.images.first
                : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=300&fit=crop',
            fit: BoxFit.cover,
          ),
        ),
        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        // Store Name Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Text(
              store.shopName,
              style: CommonStyle.heading2.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
