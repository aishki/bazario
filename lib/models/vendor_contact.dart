class VendorContact {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String? phoneNumber;
  final String? email;
  final String? position;
  final DateTime? createdAt;

  VendorContact({
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.phoneNumber,
    this.email,
    this.position,
    this.createdAt,
  });

  factory VendorContact.fromJson(Map<String, dynamic> json) {
    return VendorContact(
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      suffix: json['suffix'],
      phoneNumber: json['phone_number'],
      email: json['contact_email'] ?? json['email'],
      position: json['position'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'suffix': suffix,
      'phone_number': phoneNumber,
      'email': email,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get fullName {
    List<String> nameParts = [];
    if (firstName != null && firstName!.isNotEmpty) nameParts.add(firstName!);
    if (middleName != null && middleName!.isNotEmpty)
      nameParts.add(middleName!);
    if (lastName != null && lastName!.isNotEmpty) nameParts.add(lastName!);
    if (suffix != null && suffix!.isNotEmpty) nameParts.add(suffix!);
    return nameParts.join(' ');
  }
}
