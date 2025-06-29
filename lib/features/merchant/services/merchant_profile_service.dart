import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../services/auth_service.dart';
import '../models/merchant_profile.dart';

class MerchantProfileService {
  static Future<MerchantProfileData> getMerchantProfile() async {
    final token = await AuthService.getToken();
    final userData = await AuthService.getUserData();
    final memberId = userData?['memberId']?.toString();

    if (token == null || memberId == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/users/get/$memberId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return MerchantProfileData.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to load merchant profile');
    }
  }

  static Future<void> updateMerchantProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String shopName,
    required String shopPhoneNumber,
    required MerchantAddress address,
    required bool isOpen,
    required TimeOfDay openTime,
    required TimeOfDay closeTime,
    required List<String> categories,
    List<String>? images,
    Map<String, dynamic>? shopMetadata,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Authentication required');
    }

    // Get current location if not provided
    String location = address.location;
    if (location.isEmpty) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        location = '${position.latitude},${position.longitude}';
      } catch (e) {
        print('Error getting location: $e');
      }
    }

    // Format times
    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }

    final payload = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': '000000', // Dummy password for update
      'metadata': {},
      'shopName': shopName,
      'shopPhoneNumber': shopPhoneNumber,
      'address': {
        'streetAddress': address.streetAddress,
        'postalCode': address.postalCode,
        'location': location,
        'city': address.city,
        'state': address.state,
        'country': address.country,
      },
      'isOpen': isOpen,
      'openTime': formatTimeOfDay(openTime),
      'closeTime': formatTimeOfDay(closeTime),
      'categories': categories,
      'images': images ?? [],
      'shopMetadata': shopMetadata ?? {},
    };

    final response = await http.put(
      Uri.parse('${ApiEndpoints.baseUrl}/users/merchant/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Failed to update merchant profile');
    }
  }

  static Future<Position> getCurrentLocation() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<void> logout() async {
    await AuthService.clearAuthData();
  }
}
