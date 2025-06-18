import 'package:flutter/material.dart';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutDialog({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Logout',
        style: CommonStyle.heading4,
      ),
      content: Text(
        'Are you sure you want to logout?',
        style: CommonStyle.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onLogout,
          style: CommonStyle.primaryButton.copyWith(
            backgroundColor: MaterialStateProperty.all(AppColors.error),
            foregroundColor: MaterialStateProperty.all(AppColors.textWhite),
          ),
          child: Text(
            'Logout',
            style: CommonStyle.bodyMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
        ),
      ],
    );
  }
}
