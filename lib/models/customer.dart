class Customer {
  final String id;
  final String email;
  final String? profileUrl;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String username;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  Customer({
    required this.id,
    required this.email,
    this.profileUrl,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    required this.username,
    this.phoneNumber,
    this.address,
    this.city,
    this.postalCode,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profileUrl: json['profile_url'],
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      suffix: json['suffix'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'email': email,
      'profile_url': profileUrl,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'suffix': suffix,
      'username': username,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // String get fullName {
  //   List<String> nameParts = [];
  //   nameParts.add(firstName);
  //   if (middleName != null && middleName!.isNotEmpty)
  //     nameParts.add(middleName!);
  //   nameParts.add(lastName);
  //   if (suffix != null && suffix!.isNotEmpty) nameParts.add(suffix!);
  //   return nameParts.join(' ');
  // }
}
