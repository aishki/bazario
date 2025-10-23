class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int stock;
  final String category;
  final String? businessPartnerId;
  final String? addedBy;
  final DateTime? createdAt;

  // ✅ New fields
  final String? businessPartnerName;
  final String? businessLogo;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.stock,
    required this.category,
    this.businessPartnerId,
    this.addedBy,
    this.createdAt,
    this.businessPartnerName,
    this.businessLogo,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      category: json['category'] ?? 'others',
      businessPartnerId: json['business_partner_id'],
      addedBy: json['added_by'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      // ✅ Parse new fields
      businessPartnerName: json['business_partner_name'],
      businessLogo: json['business_logo'],
    );
  }
}
