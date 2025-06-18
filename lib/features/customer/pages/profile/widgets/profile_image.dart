import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;

  const ProfileImage({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundLight,
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.secondary,
                  );
                },
              ),
            )
          : Icon(
              Icons.person,
              size: 60,
              color: AppColors.secondary,
            ),
    );
  }
}
