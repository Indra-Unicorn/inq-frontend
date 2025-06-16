class AddressResponse {
  final String streetAddress;
  final String postalCode;
  final String location;
  final String city;
  final String state;
  final String country;

  AddressResponse({
    required this.streetAddress,
    required this.postalCode,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      streetAddress: json['streetAddress'],
      postalCode: json['postalCode'],
      location: json['location'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
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
