import 'vendor_contact.dart';

class SocialLinks {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? website;
  final String? tiktok;
  final String? youtube;

  SocialLinks({
    this.facebook,
    this.instagram,
    this.twitter,
    this.website,
    this.tiktok,
    this.youtube,
  });

  factory SocialLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SocialLinks();

    return SocialLinks(
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      website: json['website'],
      tiktok: json['tiktok'],
      youtube: json['youtube'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'website': website,
      'tiktok': tiktok,
      'youtube': youtube,
    };
  }
}

class Vendor {
  final String id;
  final String businessName;
  final String? description;
  final String? logoUrl;
  final SocialLinks socialLinks;
  final bool verified;
  final String? businessCategory;
  final DateTime createdAt;
  final VendorContact? contact;

  Vendor({
    required this.id,
    required this.businessName,
    this.description,
    this.logoUrl,
    required this.socialLinks,
    required this.verified,
    this.businessCategory,
    required this.createdAt,
    this.contact,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? '',
      businessName: json['business_name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      socialLinks: SocialLinks.fromJson(json['social_links']),
      verified: json['verified'] == true || json['verified'] == 1,
      businessCategory: json['business_category'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      contact: json['first_name'] != null || json['email'] != null
          ? VendorContact.fromJson(json)
          : null,
    );
  }

  factory Vendor.minimal({required String id, required String businessName}) {
    return Vendor(
      id: id,
      businessName: businessName,
      description: null,
      logoUrl: null,
      socialLinks: SocialLinks(),
      verified: false,
      businessCategory: null,
      createdAt: DateTime.now(),
      contact: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'description': description,
      'logo_url': logoUrl,
      'social_links': socialLinks.toJson(),
      'verified': verified,
      'business_category': businessCategory,
      'created_at': createdAt.toIso8601String(),
      if (contact != null) 'contact_info': contact!.toJson(),
    };
  }
}
