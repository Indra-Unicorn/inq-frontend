class Shop {
  final String shopId;
  final String shopName;
  final String? shopPhoneNumber;
  final ShopAddress address;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final double rating;
  final int ratingCount;
  final List<String> categories;
  final List<String> images;
  final Map<String, dynamic> metadata;

  Shop({
    required this.shopId,
    required this.shopName,
    this.shopPhoneNumber,
    required this.address,
    required this.isOpen,
    this.openTime,
    this.closeTime,
    required this.rating,
    required this.ratingCount,
    required this.categories,
    required this.images,
    required this.metadata,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'],
      shopName: json['shopName'],
      shopPhoneNumber: json['shopPhoneNumber'],
      address: json['address'] != null
          ? ShopAddress.fromJson(json['address'])
          : ShopAddress(
              streetAddress: '',
              postalCode: '',
              location: '',
              city: '',
              state: '',
              country: '',
            ),
      isOpen: json['isOpen'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
}

class ShopAddress {
  final String streetAddress;
  final String postalCode;
  final String location;
  final String city;
  final String state;
  final String country;

  ShopAddress({
    required this.streetAddress,
    required this.postalCode,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      streetAddress: json['streetAddress'] ?? '',
      postalCode: json['postalCode'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }
}
