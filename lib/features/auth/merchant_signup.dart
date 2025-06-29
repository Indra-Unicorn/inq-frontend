import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../shared/constants/api_endpoints.dart';
import '../../shared/constants/app_colors.dart';

class MerchantSignUpPage extends StatefulWidget {
  const MerchantSignUpPage({super.key});

  @override
  State<MerchantSignUpPage> createState() => _MerchantSignUpPageState();
}

class _MerchantSignUpPageState extends State<MerchantSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  String? _location;
  List<String> _selectedCategories = [];

  final List<String> _categories = [
    'Restaurant',
    'Cafe',
    'Retail',
    'Salon',
    'Gym',
    'Clinic',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _shopPhoneController.dispose();
    _shopNameController.dispose();
    _streetAddressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission is required'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _location = '${position.latitude},${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectTime(bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_openTime == null || _closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select opening and closing times'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneController.text,
        'shopPhoneNumber': _shopPhoneController.text,
        'metadata': {
          'deviceType': Platform.isAndroid ? 'ANDROID' : 'IOS',
          'appVersion': '1.0.0',
          'osVersion': Platform.operatingSystemVersion,
        },
        'shopName': _shopNameController.text,
        'address': {
          'streetAddress': _streetAddressController.text,
          'postalCode': _postalCodeController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'country': _countryController.text,
        },
        'isOpen': false,
        'openTime':
            '${_openTime!.hour.toString().padLeft(2, '0')}:${_openTime!.minute.toString().padLeft(2, '0')}',
        'closeTime':
            '${_closeTime!.hour.toString().padLeft(2, '0')}:${_closeTime!.minute.toString().padLeft(2, '0')}',
        'categories': _selectedCategories,
        'images': [], // Empty array for now, can be implemented later
        'shopMetadata': {
          'rating': 0.0,
          'ratingCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      };

      // Add location only if it's available
      if (_location != null) {
        requestBody['address']['location'] = _location;
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.merchantSignup}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      print('Merchant Signup Response: ${response.statusCode}');
      print('Response Body: $data');

      if (data['success'] == true) {
        print('Signup successful, proceeding with navigation');
        // Store token and login state
        final prefs = await SharedPreferences.getInstance();
        final token = data['data']['token'];
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);

        // Register FCM token
        await _registerFCMToken(token);

        if (mounted) {
          print('Widget is mounted, showing success message and navigating');
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ??
                  'Signup successful! Please login to continue.'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate to login page
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          print('Widget is not mounted, cannot navigate');
        }
      } else {
        print('Signup failed: ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Signup failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerFCMToken(String jwtToken) async {
    try {
      final decodedToken = JwtDecoder.decode(jwtToken);
      final userId = decodedToken['memberId'];
      final userType = decodedToken['userType'];

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
      final deviceModel = Platform.operatingSystemVersion;
      final appVersion = '1.0.0';
      final osVersion = Platform.operatingSystemVersion;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.registerFCMToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'userId': userId,
          'userType': userType,
          'fcmToken': fcmToken,
          'deviceType': deviceType,
          'deviceModel': deviceModel,
          'appVersion': appVersion,
          'osVersion': osVersion,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
        print('Failed to register FCM token: ${data['message']}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Merchant Sign Up',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
                const SizedBox(height: 24),

                // Basic Information
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length < 2 || value.length > 100) {
                      return 'Name must be between 2 and 100 characters';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6 || value.length > 100) {
                      return 'Password must be between 6 and 100 characters';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Shop Information
                Text(
                  'Shop Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _shopNameController,
                  label: 'Shop Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Shop name is required';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _shopPhoneController,
                  label: 'Shop Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Shop phone number is required';
                    }
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _streetAddressController,
                  label: 'Street Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Street address is required';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                ),
                _buildInputField(
                  controller: _cityController,
                  label: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _stateController,
                  label: 'State',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'State is required';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _countryController,
                  label: 'Country',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(
                          Icons.location_on,
                          color: AppColors.textWhite,
                        ),
                        label: Text(
                          _location ?? 'Get Location (Optional)',
                          style: TextStyle(color: AppColors.textWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Business Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectTime(true),
                        icon: Icon(
                          Icons.access_time,
                          color: AppColors.textWhite,
                        ),
                        label: Text(
                          _openTime?.format(context) ?? 'Opening Time',
                          style: TextStyle(color: AppColors.textWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectTime(false),
                        icon: Icon(
                          Icons.access_time,
                          color: AppColors.textWhite,
                        ),
                        label: Text(
                          _closeTime?.format(context) ?? 'Closing Time',
                          style: TextStyle(color: AppColors.textWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: AppColors.backgroundLight,
                      selectedColor: AppColors.primary,
                      checkmarkColor: AppColors.textWhite,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textWhite),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Already have an account? Log in',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        style: TextStyle(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
