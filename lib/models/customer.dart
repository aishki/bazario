class Customer {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    this.phoneNumber,
    this.address,
    this.city,
    this.postalCode,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      suffix: json['suffix'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'suffix': suffix,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName {
    List<String> nameParts = [];
    nameParts.add(firstName);
    if (middleName != null && middleName!.isNotEmpty)
      nameParts.add(middleName!);
    nameParts.add(lastName);
    if (suffix != null && suffix!.isNotEmpty) nameParts.add(suffix!);
    return nameParts.join(' ');
  }
}
