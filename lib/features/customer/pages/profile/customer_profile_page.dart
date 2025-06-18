import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_image.dart';
import 'widgets/user_info.dart';
import 'widgets/logout_button.dart';
import 'widgets/logout_dialog.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _profileService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogoutDialog(
          onLogout: () async {
            try {
              await _profileService.logout();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            } catch (e) {
              print('Logout error: $e');
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ProfileImage(
                                  imageUrl: _userData?['profileImage'],
                                ),
                                const SizedBox(height: 16),
                                UserInfo(
                                  name: _userData?['name'],
                                  createdAt:
                                      _userData?['createdAt']?.toString(),
                                  phoneNumber: _userData?['phoneNumber'],
                                  inQoin: _userData?['inQoin'],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
            Column(
              children: [
                LogoutButton(
                  onPressed: _showLogoutDialog,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
