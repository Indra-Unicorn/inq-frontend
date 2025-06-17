import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../shared/constants/api_endpoints.dart';
import '../../shared/constants/app_constants.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Decode JWT token to get memberId
      final decodedToken = JwtDecoder.decode(token);
      final memberId = decodedToken['memberId'];

      if (memberId == null) {
        throw Exception('Invalid token');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getUserById}/$memberId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _userData = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load user data');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF181111),
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xFF181111),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Section
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Profile Image
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(64),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      _userData?['profileImage'] ?? 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // User Name and Member Info
                              Column(
                                children: [
                                  Text(
                                    _userData?['name'] ?? 'User Name',
                                    style: const TextStyle(
                                      color: Color(0xFF181111),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.015,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Member since ${_userData?['createdAt']?.toString().substring(0, 4) ?? '2024'}',
                                    style: const TextStyle(
                                      color: Color(0xFF886364),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_userData?['phoneNumber'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _userData!['phoneNumber'],
                                      style: const TextStyle(
                                        color: Color(0xFF886364),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  if (_userData?['inQoin'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_userData!['inQoin']} inQoins',
                                      style: const TextStyle(
                                        color: Color(0xFF886364),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Add bottom padding to prevent overlap with logout button
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
            ),

            // Bottom Section with Logout
            Column(
              children: [
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F0F0),
                        foregroundColor: const Color(0xFF181111),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFF181111),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Color(0xFF886364),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF886364),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  // Set isLoggedIn to false
                  await prefs.setBool('isLoggedIn', false);
                  // Remove the JWT token
                  await prefs.remove(AppConstants.tokenKey);
                  // Clear all other stored data
                  await prefs.clear();
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    // Navigate to login page and clear all previous routes
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      '/', 
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print('Logout error: $e');
                  // Even if there's an error, try to navigate to login
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE82630),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}