import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'dart:io';
import '../../shared/constants/api_endpoints.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/otp_input_row.dart';
import '../../services/auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String sessionId;
  final String? returnTo;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.sessionId,
    this.returnTo,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with CodeAutoFill {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  late String _currentSessionId;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.sessionId;
    _startResendTimer();
    if (!kIsWeb) {
      listenForCode();
    }
  }

  @override
  void codeUpdated() {
    final incoming = code ?? '';
    if (incoming.length == 4) {
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = incoming[i];
      }
      _verifyOTP();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    if (!kIsWeb) cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
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

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.customerLoginInitiate}?phoneNumber=${Uri.encodeQueryComponent(widget.phoneNumber)}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _currentSessionId = data['data']['session_id'];
        for (var c in _controllers) {
          c.clear();
        }
        _startResendTimer();
        if (!kIsWeb) {
          listenForCode();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(data['message'] ?? 'Failed to resend OTP')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.customerPhoneLogin}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'sessionId': _currentSessionId,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Store token and login state using AuthService
        final token = data['data']['token'];
        final userDataRaw = data['data']['user'] ?? {};
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(userDataRaw);

        await AuthService.storeAuthData(
          token: token,
          userData: userData,
          refreshToken: data['data']['refreshToken'],
        );

        // Register FCM token
        await _registerFCMToken(token);

        if (mounted) {
          final destination = widget.returnTo;
          if (destination != null && destination != '/customer-dashboard') {
            // Push the dashboard as the base, then the destination on top,
            // so the back button returns to the dashboard instead of a blank screen.
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/customer-dashboard',
              (route) => false,
            );
            Navigator.pushNamed(context, destination);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, '/customer-dashboard', (route) => false);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to verify OTP')),
        );
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
      final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
      final deviceModel = Platform.operatingSystemVersion;
      final appVersion =
          '1.0.0'; // You might want to get this from your app's version
      final osVersion = Platform.operatingSystemVersion;

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
      // Silently handle FCM token registration errors
    } catch (e) {
      // Silently handle FCM token registration errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Phone Number',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 4-digit code sent to ${widget.phoneNumber}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              OtpInputRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.015,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: (_isLoading || _resendCooldown > 0)
                      ? null
                      : _resendOTP,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend Code in ${_resendCooldown}s'
                        : 'Resend Code',
                    style: TextStyle(
                      color: _resendCooldown > 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontSize: 14,
                      decoration: _resendCooldown > 0
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
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
