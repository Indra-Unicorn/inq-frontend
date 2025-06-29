class MerchantData {
  final String merchantId;
  final String email;
  final String name;
  final String phoneNumber;
  final double inQoin;
  final String status;
  final DateTime createdAt;
  final List<ShopData> shops;

  MerchantData({
    required this.merchantId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.inQoin,
    required this.status,
    required this.createdAt,
    required this.shops,
  });

  factory MerchantData.fromJson(Map<String, dynamic> json) {
    return MerchantData(
      merchantId: json['merchantId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      inQoin: (json['inQoin'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      shops: (json['shops'] as List<dynamic>?)
              ?.map((shop) => ShopData.fromJson(shop))
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
      'createdAt': createdAt.toIso8601String(),
      'shops': shops.map((shop) => shop.toJson()).toList(),
    };
  }
}

class ShopData {
  final String shopId;
  final String shopName;
  final String shopPhoneNumber;
  final AddressData address;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final List<QueueResponse> queueResponses;

  ShopData({
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
    required this.queueResponses,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      shopPhoneNumber: json['shopPhoneNumber'] ?? '',
      address: AddressData.fromJson(json['address'] ?? {}),
      isOpen: json['isOpen'] ?? false,
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      queueResponses: (json['queueResponses'] as List<dynamic>?)
              ?.map((queue) => QueueResponse.fromJson(queue))
              .toList() ??
          [],
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
      'queueResponses': queueResponses.map((queue) => queue.toJson()).toList(),
    };
  }
}

class AddressData {
  final String streetAddress;
  final String postalCode;
  final String location;
  final String city;
  final String state;
  final String country;

  AddressData({
    required this.streetAddress,
    required this.postalCode,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
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
}

class QueueResponse {
  final String shopId;
  final String status;
  final String name;
  final int size;
  final int maxSize;
  final int processed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double inQoinRate;
  final int alertNumber;
  final int bufferNumber;
  final int avgTimePerCustomer;
  final bool hasCapacity;
  final bool full;
  final String qid;

  QueueResponse({
    required this.shopId,
    required this.status,
    required this.name,
    required this.size,
    required this.maxSize,
    required this.processed,
    required this.createdAt,
    required this.updatedAt,
    required this.inQoinRate,
    required this.alertNumber,
    required this.bufferNumber,
    required this.avgTimePerCustomer,
    required this.hasCapacity,
    required this.full,
    required this.qid,
  });

  factory QueueResponse.fromJson(Map<String, dynamic> json) {
    return QueueResponse(
      shopId: json['shopId'] ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      maxSize: json['maxSize'] ?? 0,
      processed: json['processed'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      inQoinRate: (json['inQoinRate'] ?? 0.0).toDouble(),
      alertNumber: json['alertNumber'] ?? 0,
      bufferNumber: json['bufferNumber'] ?? 0,
      avgTimePerCustomer: json['avgTimePerCustomer'] ?? 0,
      hasCapacity: json['hasCapacity'] ?? false,
      full: json['full'] ?? false,
      qid: json['qid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'status': status,
      'name': name,
      'size': size,
      'maxSize': maxSize,
      'processed': processed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'inQoinRate': inQoinRate,
      'alertNumber': alertNumber,
      'bufferNumber': bufferNumber,
      'avgTimePerCustomer': avgTimePerCustomer,
      'hasCapacity': hasCapacity,
      'full': full,
      'qid': qid,
    };
  }
}
