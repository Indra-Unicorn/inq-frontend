import 'package:flutter/material.dart';
import '../../../../../shared/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final VoidCallback? onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.onBackPressed,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
              child: Column(
                children: [
                  // Top nav row
                  Row(
                    children: [
                      _NavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: onBackPressed,
                      ),
                      const Expanded(
                        child: Text(
                          'My Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      // Spacer to balance the back button
                      const SizedBox(width: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Avatar overlapping the bottom of the header
        Positioned(
          bottom: -52,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: profileImage != null && profileImage!.isNotEmpty
                          ? Image.network(
                              profileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _initials(name),
                            )
                          : _initials(name),
                    ),
                  ),
                  // Camera edit button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onEditAvatar,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initials(String? name) {
    final letter = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      color: AppColors.primary.withOpacity(0.15),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
