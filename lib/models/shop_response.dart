import 'address_response.dart';

class ShopResponse {
  final String shopId;
  final String shopName;
  final AddressResponse? address;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final Map<String, dynamic> metadata;

  ShopResponse({
    required this.shopId,
    required this.shopName,
    this.address,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.images,
    required this.metadata,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      shopId: json['shopId'],
      shopName: json['shopName'],
      address: json['address'] != null
          ? AddressResponse.fromJson(json['address'])
          : null,
      isOpen: json['isOpen'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'],
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'address': address?.toJson(),
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
}
