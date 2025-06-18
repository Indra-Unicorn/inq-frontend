import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: CommonStyle.secondaryButton.copyWith(
          backgroundColor: MaterialStateProperty.all(AppColors.error),
          foregroundColor: MaterialStateProperty.all(AppColors.textWhite),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppColors.textWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: CommonStyle.bodyLarge.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
