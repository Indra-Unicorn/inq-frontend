import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/constants/api_endpoints.dart';

class MerchantProfile extends StatefulWidget {
  const MerchantProfile({super.key});

  @override
  State<MerchantProfile> createState() => _MerchantProfileState();
}

class _MerchantProfileState extends State<MerchantProfile> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _merchantData;
  Map<String, dynamic>? _shopData;
  bool _isOpen = false;
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 17, minute: 0);
  List<String> _categories = [];
  final List<String> _availableCategories = [
    'Restaurant',
    'Gym',
    'Salon',
    'Spa',
    'Retail',
    'Cafe',
    'Bar',
    'Clinic',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('token');

    if (!isLoggedIn || token == null) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
      return;
    }

    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final memberId = prefs.getString('memberId');
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn || token == null || memberId == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/users/get/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _merchantData = data['data'];
          _shopData = data['data']['shops'][0];
          _isOpen = _shopData?['isOpen'] ?? false;
          _openTime = _parseTimeString(_shopData?['openTime'] ?? '09:00:00');
          _closeTime = _parseTimeString(_shopData?['closeTime'] ?? '17:00:00');
          _categories = List<String>.from(_shopData?['categories'] ?? []);
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load merchant data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _updateMerchantData() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('Error getting location: $e');
      }

      // Prepare request payload
      final payload = {
        // Basic merchant information
        'name': _merchantData?['name'],
        'email': _merchantData?['email'],
        'phoneNumber': _merchantData?['phoneNumber'],
        'password': '000000', // Adding dummy password
        'metadata': _merchantData?['metadata'] ?? {},
        
        // Shop details
        'shopName': _shopData?['shopName'],
        'address': {
          'streetAddress': _shopData?['address']['streetAddress'],
          'postalCode': _shopData?['address']['postalCode'],
          'location': position != null ? '${position.latitude},${position.longitude}' : _shopData?['address']['location'],
          'city': _shopData?['address']['city'],
          'state': _shopData?['address']['state'],
          'country': _shopData?['address']['country'],
        },
        'isOpen': _isOpen,
        'openTime': _formatTimeOfDay(_openTime),
        'closeTime': _formatTimeOfDay(_closeTime),
        'categories': _categories,
        'images': _shopData?['images'] ?? [],
        'shopMetadata': _shopData?['metadata'] ?? {},
      };

      // Print the payload for debugging
      print('Update Merchant Request Payload:');
      print(jsonEncode(payload));

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/users/merchant/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      // Print the response for debugging
      print('Update Merchant Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFFE8B4B7),
          ),
        );
        await _loadMerchantData();
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Update Merchant Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the location in the shop data
      if (_shopData != null) {
        _shopData!['address']['location'] = '${position.latitude},${position.longitude}';
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully'),
          backgroundColor: Color(0xFFE8B4B7),
        ),
      );

      // Save the changes
      await _updateMerchantData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Store Profile',
                      style: TextStyle(
                        color: Color(0xFF191010),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _isUpdating ? null : _updateMerchantData,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Status Card
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Shop Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191010),
                                  ),
                                ),
                                Switch(
                                  value: _isOpen,
                                  onChanged: (value) {
                                    setState(() {
                                      _isOpen = value;
                                    });
                                  },
                                  activeColor: const Color(0xFFE9B8BA),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeSelector(
                                    'Opening Time',
                                    _openTime.format(context),
                                    () => _selectTime(context, true),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimeSelector(
                                    'Closing Time',
                                    _closeTime.format(context),
                                    () => _selectTime(context, false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Shop Information Card
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shop Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191010),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Shop Name', _shopData?['shopName'] ?? ''),
                            const SizedBox(height: 12),
                            _buildInfoRow('Address', '${_shopData?['address']['streetAddress'] ?? ''}, ${_shopData?['address']['city'] ?? ''}, ${_shopData?['address']['state'] ?? ''}, ${_shopData?['address']['postalCode'] ?? ''}'),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _updateLocation,
                                icon: const Icon(Icons.location_on_outlined),
                                label: const Text('Update Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF191010),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Categories Card
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191010),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableCategories.map((category) {
                                final isSelected = _categories.contains(category);
                                return FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        _categories.add(category);
                                      } else {
                                        _categories.remove(category);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFFE9B8BA),
                                  labelStyle: TextStyle(
                                    color: isSelected ? const Color(0xFF191010) : const Color(0xFF8B5B5C),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Merchant Information Card
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Merchant Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191010),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Name', _merchantData?['name'] ?? ''),
                            const SizedBox(height: 12),
                            _buildInfoRow('Email', _merchantData?['email'] ?? ''),
                            const SizedBox(height: 12),
                            _buildInfoRow('Phone', _merchantData?['phoneNumber'] ?? ''),
                            const SizedBox(height: 12),
                            _buildInfoRow('Status', _merchantData?['status'] ?? ''),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              // Set isLoggedIn to false
                              await prefs.setBool('isLoggedIn', false);
                              // Remove the JWT token
                              await prefs.remove('token');
                              // Clear all other stored data
                              await prefs.clear();
                              
                              if (mounted) {
                                // Use pushReplacementNamed instead of pushNamedAndRemoveUntil
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            } catch (e) {
                              print('Logout error: $e');
                              // Even if there's an error, try to navigate to login
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE9242A),
                            foregroundColor: const Color(0xFFFCF8F8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B5B5C),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191010),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF8B5B5C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B5B5C),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF191010),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 