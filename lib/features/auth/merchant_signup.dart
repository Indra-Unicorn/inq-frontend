import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_constants.dart';
import '../../services/auth_service.dart';
import 'models/merchant_signup_data.dart';
import 'services/merchant_signup_service.dart';
import 'services/location_service.dart';
import 'widgets/basic_information_section.dart';
import 'widgets/shop_information_section.dart';
import 'widgets/business_hours_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/shop_images_section.dart';

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
  List<dynamic> _selectedImages = []; // Can be File or Uint8List depending on platform

  @override
  void initState() {
    super.initState();
    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final route = await AuthService.dashboardRouteForCurrentUser();
    if (!mounted || route == null) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

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
    final result = await LocationService.getCurrentLocationWithStatus();
    
    if (result.success) {
      setState(() {
        _location = result.location;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location obtained successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        _showLocationErrorDialog(result);
      }
    }
  }

  void _showLocationErrorDialog(LocationResult result) {
    String title = 'Location Access Required';
    String content = result.message;
    List<Widget> actions = [];

    switch (result.error) {
      case LocationError.serviceDisabled:
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ];
        break;

      case LocationError.permissionDenied:
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try again after user dismissed dialog
              Future.delayed(const Duration(milliseconds: 500), () {
                _getCurrentLocation();
              });
            },
            child: const Text('Try Again'),
          ),
        ];
        break;

      case LocationError.permissionDeniedForever:
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ];
        break;

      case LocationError.timeout:
      case LocationError.unknown:
      default:
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _getCurrentLocation();
            },
            child: const Text('Try Again'),
          ),
        ];
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
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

  void _onCategoryChanged(String category, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
  }

  double _getProgressPercentage() {
    int completedSteps = 0;
    int totalSteps = 5;

    // Basic information
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty) {
      completedSteps++;
    }

    // Shop information
    if (_shopNameController.text.isNotEmpty &&
        _shopPhoneController.text.isNotEmpty &&
        _streetAddressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _countryController.text.isNotEmpty) {
      completedSteps++;
    }

    // Business hours
    if (_openTime != null && _closeTime != null) {
      completedSteps++;
    }

    // Categories
    if (_selectedCategories.isNotEmpty) {
      completedSteps++;
    }

    // Images (optional, always counts as completed)
    completedSteps++;

    return completedSteps / totalSteps;
  }

  Future<void> _handleSignup() async {
    
    // Check form validation
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check business hours
    if (_openTime == null || _closeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select opening and closing times'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Check categories
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
      final signupData = MerchantSignupData(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        shopPhoneNumber: _shopPhoneController.text,
        shopName: _shopNameController.text,
        streetAddress: _streetAddressController.text,
        postalCode: _postalCodeController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        location: _location,
        openTime: _openTime,
        closeTime: _closeTime,
        categories: _selectedCategories,
      );

      final data = await MerchantSignupService.signup(signupData, _selectedImages);

      if (data['success'] == true) {
        final responseData =
            (data['data'] != null && data['data'] is Map)
                ? Map<String, dynamic>.from(data['data'] as Map)
                : <String, dynamic>{};
        final token = responseData['token'] as String?;

        if (token != null && token.isNotEmpty) {
          final userData = {...responseData}..remove('token');
          await AuthService.storeAuthData(
            token: token,
            userData: userData,
            refreshToken: responseData['refreshToken'] as String?,
          );
          await MerchantSignupService.registerFCMToken(token);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ??
                  'Signup successful! Please login to continue.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Signup failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final progress = _getProgressPercentage();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header with progress
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Merchant Sign Up',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete your business profile',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.border.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Basic Information Section
                      BasicInformationSection(
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        phoneController: _phoneController,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),

                      const SizedBox(height: 24),

                      // Shop Information Section
                      ShopInformationSection(
                        shopNameController: _shopNameController,
                        shopPhoneController: _shopPhoneController,
                        streetAddressController: _streetAddressController,
                        postalCodeController: _postalCodeController,
                        cityController: _cityController,
                        stateController: _stateController,
                        countryController: _countryController,
                        location: _location,
                        onGetLocation: _getCurrentLocation,
                      ),

                      const SizedBox(height: 24),

                      // Business Hours Section
                      BusinessHoursSection(
                        openTime: _openTime,
                        closeTime: _closeTime,
                        onSelectOpenTime: () => _selectTime(true),
                        onSelectCloseTime: () => _selectTime(false),
                      ),

                      const SizedBox(height: 24),

                      // Categories Section
                      CategoriesSection(
                        selectedCategories: _selectedCategories,
                        onCategoryChanged: _onCategoryChanged,
                      ),

                      const SizedBox(height: 24),

                      // Shop Images Section
                      ShopImagesSection(
                        selectedImages: _selectedImages,
                        onImagesChanged: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                      ),

                      const SizedBox(height: 40),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Creating Account...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Create Merchant Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),

                      const SizedBox(height: 32),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Continue as Guest Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/customer-dashboard');
                          },
                          icon: Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Continue as Guest',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
