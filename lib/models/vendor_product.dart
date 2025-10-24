class VendorProduct {
  final String id;
  final String vendorId;
  String? name;
  String? description;
  String? imageUrl;
  final bool isFeatured;
  final DateTime createdAt;

  VendorProduct({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.imageUrl,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      name: json['name'] ?? 'Unnamed',
      description: json['description'],
      imageUrl: json['image_url'],
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "vendor_id": vendorId,
      "name": name,
      "description": description,
      "image_url": imageUrl,
      "is_featured": isFeatured ? 1 : 0,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
