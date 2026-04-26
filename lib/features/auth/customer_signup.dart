import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../shared/constants/api_endpoints.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/utils/platform_utils.dart';
import '../../shared/widgets/otp_input_row.dart';
import '../../services/auth_service.dart';

class CustomerSignUpPage extends StatefulWidget {
  final String? prefillPhone;
  final String? returnTo;

  const CustomerSignUpPage({super.key, this.prefillPhone, this.returnTo});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage>
    with CodeAutoFill {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _otpSent = false;
  String? _sessionId;
  bool _isPhoneEnabled = true;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    if (widget.prefillPhone != null && widget.prefillPhone!.isNotEmpty) {
      _phoneController.text = widget.prefillPhone!;
    }
    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final route = await AuthService.dashboardRouteForCurrentUser();
    if (!mounted || route == null) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  @override
  void codeUpdated() {
    final incoming = code ?? '';
    if (incoming.length == 4) {
      for (int i = 0; i < 4; i++) {
        _otpControllers[i].text = incoming[i];
      }
      _verifyOTP();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    if (!kIsWeb) cancel();
    _fullNameController.dispose();
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _initiateSignup() async {
    if (_fullNameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.customerPhoneSignupInitiate}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _fullNameController.text,
          'phoneNumber': _phoneController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        for (var c in _otpControllers) {
          c.clear();
        }
        setState(() {
          _otpSent = true;
          _sessionId = data['data']['session_id'];
          _isPhoneEnabled = false;
        });
        _startResendTimer();
        if (!kIsWeb) {
          listenForCode();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('OTP sent successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to send OTP'),
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

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.customerPhoneSignup}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _fullNameController.text,
          'phoneNumber': _phoneController.text,
          'sessionId': _sessionId,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      final isSuccess = data['success'] == true &&
          (response.statusCode == 200 || response.statusCode == 201);

      if (isSuccess) {
        final responseData = Map<String, dynamic>.from(data['data'] ?? {});
        final token = responseData['token'] as String;

        // User fields are flat inside data — exclude the token itself
        final Map<String, dynamic> userData = {
          ...responseData,
        }..remove('token');

        await AuthService.storeAuthData(
          token: token,
          userData: userData,
          refreshToken: responseData['refreshToken'],
        );

        await _registerFCMToken(token);

        if (mounted) {
          final destination = widget.returnTo ?? '/customer-dashboard';
          Navigator.pushNamedAndRemoveUntil(
              context, destination, (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to verify OTP'),
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

  Future<void> _registerFCMToken(String jwtToken) async {
    try {
      // Decode JWT token to get user information
      final decodedToken = JwtDecoder.decode(jwtToken);
      final userId = decodedToken['memberId'];
      final userType = decodedToken['userType'];

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      // Get device information
      final deviceType = PlatformUtils.getDeviceType();
      final deviceModel = PlatformUtils.getDeviceModel();
      final appVersion = PlatformUtils.getAppVersion();
      final osVersion = PlatformUtils.getOSVersion();

      // Register FCM token
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
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
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
                  Expanded(
                    child: Text(
                      'Customer Sign Up',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please fill in your details to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    _buildInputField(
                      controller: _fullNameController,
                      placeholder: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      enabled: !_otpSent,
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: 'Phone Number',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      enabled: _isPhoneEnabled,
                    ),

                    if (_otpSent) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OtpInputRow(
                        controllers: _otpControllers,
                        focusNodes: _otpFocusNodes,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_otpSent ? _verifyOTP : _initiateSignup),
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
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _otpSent ? 'Verify OTP' : 'Send OTP',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),

                    if (_otpSent) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: (_isLoading || _resendCooldown > 0)
                            ? null
                            : _initiateSignup,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend OTP in ${_resendCooldown}s'
                              : 'Resend OTP',
                          style: TextStyle(
                            color: _resendCooldown > 0
                                ? AppColors.textSecondary
                                : AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

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

                    const SizedBox(height: 16),

                    // Merchant signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you a merchant? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/merchant-signup');
                          },
                          child: Text(
                            'Sign Up Here',
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.backgroundLight : AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        style: TextStyle(
          color: AppColors.textPrimary.withOpacity(enabled ? 1.0 : 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: placeholder,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
