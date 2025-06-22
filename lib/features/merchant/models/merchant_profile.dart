import 'package:flutter/material.dart';

class MerchantAddress {
  final String streetAddress;
  final String postalCode;
  final String location;
  final String city;
  final String state;
  final String country;

  MerchantAddress({
    required this.streetAddress,
    required this.postalCode,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  factory MerchantAddress.fromJson(Map<String, dynamic> json) {
    return MerchantAddress(
      streetAddress: json['streetAddress'] ?? '',
      postalCode: json['postalCode'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetAddress': streetAddress,
      'postalCode': postalCode,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
    };
  }

  String get fullAddress {
    return '$streetAddress, $city, $state $postalCode, $country';
  }
}

class MerchantShop {
  final String shopId;
  final String shopName;
  final String shopPhoneNumber;
  final MerchantAddress address;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final Map<String, dynamic> metadata;

  MerchantShop({
    required this.shopId,
    required this.shopName,
    required this.shopPhoneNumber,
    required this.address,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.images,
    required this.metadata,
  });

  factory MerchantShop.fromJson(Map<String, dynamic> json) {
    return MerchantShop(
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      shopPhoneNumber: json['shopPhoneNumber'] ?? '',
      address: MerchantAddress.fromJson(json['address'] ?? {}),
      isOpen: json['isOpen'] ?? false,
      openTime: json['openTime'] ?? '09:00:00',
      closeTime: json['closeTime'] ?? '17:00:00',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'shopPhoneNumber': shopPhoneNumber,
      'address': address.toJson(),
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'rating': rating,
      'ratingCount': ratingCount,
      'categories': categories,
      'images': images,
      'metadata': metadata,
    };
  }

  TimeOfDay get openTimeOfDay {
    final parts = openTime.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  TimeOfDay get closeTimeOfDay {
    final parts = closeTime.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String get formattedOpenTime {
    final time = openTimeOfDay;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedCloseTime {
    final time = closeTimeOfDay;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get ratingDisplay {
    if (ratingCount == 0) return 'No ratings yet';
    return '${rating.toStringAsFixed(1)} (${ratingCount} reviews)';
  }

  Color get statusColor {
    return isOpen ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  }

  String get statusText {
    return isOpen ? 'Open' : 'Closed';
  }
}

class MerchantProfileData {
  final String merchantId;
  final String email;
  final String name;
  final String phoneNumber;
  final double inQoin;
  final String status;
  final Map<String, dynamic> metadata;
  final String createdAt;
  final List<MerchantShop> shops;

  MerchantProfileData({
    required this.merchantId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.inQoin,
    required this.status,
    required this.metadata,
    required this.createdAt,
    required this.shops,
  });

  factory MerchantProfileData.fromJson(Map<String, dynamic> json) {
    return MerchantProfileData(
      merchantId: json['merchantId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      inQoin: (json['inQoin'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      metadata: json['metadata'] ?? {},
      createdAt: json['createdAt'] ?? '',
      shops: (json['shops'] as List<dynamic>?)
              ?.map((shop) => MerchantShop.fromJson(shop))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'inQoin': inQoin,
      'status': status,
      'metadata': metadata,
      'createdAt': createdAt,
      'shops': shops.map((shop) => shop.toJson()).toList(),
    };
  }

  MerchantShop? get primaryShop {
    return shops.isNotEmpty ? shops.first : null;
  }

  String get statusDisplay {
    switch (status) {
      case 'APPROVED':
        return 'Approved';
      case 'PENDING':
        return 'Pending Approval';
      case 'REJECTED':
        return 'Rejected';
      case 'SUSPENDED':
        return 'Suspended';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF4CAF50);
      case 'PENDING':
        return const Color(0xFFFF9800);
      case 'REJECTED':
        return const Color(0xFFF44336);
      case 'SUSPENDED':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get formattedCreatedAt {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  String get formattedInQoin {
    return inQoin.toStringAsFixed(2);
  }
}
