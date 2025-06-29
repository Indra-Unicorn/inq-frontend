import 'package:flutter/material.dart';
import 'dart:io';

// Model class for merchant signup data
class MerchantSignupData {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String shopPhoneNumber;
  final String shopName;
  final String streetAddress;
  final String postalCode;
  final String city;
  final String state;
  final String country;
  final String? location;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final List<String> categories;

  MerchantSignupData({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.shopPhoneNumber,
    required this.shopName,
    required this.streetAddress,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.country,
    this.location,
    this.openTime,
    this.closeTime,
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'shopPhoneNumber': shopPhoneNumber,
      'metadata': {
        'deviceType': Platform.isAndroid ? 'ANDROID' : 'IOS',
        'appVersion': '1.0.0',
        'osVersion': Platform.operatingSystemVersion,
      },
      'shopName': shopName,
      'address': {
        'streetAddress': streetAddress,
        'postalCode': postalCode,
        'city': city,
        'state': state,
        'country': country,
      },
      'isOpen': false,
      'openTime': openTime != null
          ? '${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'closeTime': closeTime != null
          ? '${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'categories': categories,
      'images': [],
      'shopMetadata': {
        'rating': 0.0,
        'ratingCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
    };

    if (location != null) {
      requestBody['address']['location'] = location;
    }

    return requestBody;
  }
}
