import 'merchant_status.dart';
import 'shop_response.dart';

class MerchantResponse {
  final String merchantId;
  final String email;
  final String name;
  final String phoneNumber;
  final double inQoin;
  final MerchantStatus status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final List<ShopResponse> shops;

  MerchantResponse({
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

  factory MerchantResponse.fromJson(Map<String, dynamic> json) {
    return MerchantResponse(
      merchantId: json['merchantId'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      inQoin: (json['inQoin'] as num).toDouble(),
      status: MerchantStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MerchantStatus.CREATED,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      shops: (json['shops'] as List)
          .map((shop) => ShopResponse.fromJson(shop))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'inQoin': inQoin,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'shops': shops.map((shop) => shop.toJson()).toList(),
    };
  }
}
