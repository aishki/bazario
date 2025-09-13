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

class ContactDisplayPreferences {
  final bool showInstagram;
  final bool showFacebook;
  final bool showPhone;
  final bool showWebsite;
  final bool showTiktok;
  final bool showTwitter;

  ContactDisplayPreferences({
    this.showInstagram = true,
    this.showFacebook = true,
    this.showPhone = true,
    this.showWebsite = false,
    this.showTiktok = false,
    this.showTwitter = false,
  });

  factory ContactDisplayPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ContactDisplayPreferences();

    return ContactDisplayPreferences(
      showInstagram: json['show_instagram'] ?? true,
      showFacebook: json['show_facebook'] ?? true,
      showPhone: json['show_phone'] ?? true,
      showWebsite: json['show_website'] ?? false,
      showTiktok: json['show_tiktok'] ?? false,
      showTwitter: json['show_twitter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_instagram': showInstagram,
      'show_facebook': showFacebook,
      'show_phone': showPhone,
      'show_website': showWebsite,
      'show_tiktok': showTiktok,
      'show_twitter': showTwitter,
    };
  }

  List<String> getSelectedContacts() {
    List<String> selected = [];
    if (showInstagram) selected.add('instagram');
    if (showFacebook) selected.add('facebook');
    if (showPhone) selected.add('phone');
    if (showWebsite) selected.add('website');
    if (showTiktok) selected.add('tiktok');
    if (showTwitter) selected.add('twitter');
    return selected.take(3).toList(); // Limit to 3 as requested
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
  final ContactDisplayPreferences contactDisplayPreferences;

  Vendor({
    required this.id,
    required this.businessName,
    required this.description,
    this.logoUrl,
    required this.socialLinks,
    required this.verified,
    this.businessCategory,
    required this.createdAt,
    this.contact,
    ContactDisplayPreferences? contactDisplayPreferences,
  }) : contactDisplayPreferences =
           contactDisplayPreferences ?? ContactDisplayPreferences();

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('vendor') ? json['vendor'] : json;

    return Vendor(
      id: data['vendor_id'] ?? data['id'] ?? '',
      businessName: data['business_name'] ?? 'Unknown',
      description: data['description'],
      logoUrl: data['logo_url'],
      socialLinks: SocialLinks.fromJson(data['social_links'] ?? {}),
      verified: data['verified'] == true || data['verified'] == 1,
      businessCategory: data['business_category'],
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      contact: data['contact_info'] != null
          ? VendorContact.fromJson(data['contact_info'])
          : null,
      contactDisplayPreferences: ContactDisplayPreferences.fromJson(
        data['contact_display_preferences'] ?? {},
      ),
    );
  }

  factory Vendor.minimal({
    required String id,
    required String businessName,
    String? description,
    String? businessCategory,
  }) {
    return Vendor(
      id: id,
      businessName: businessName,
      description: description,
      logoUrl: null,
      socialLinks: SocialLinks(),
      verified: false,
      businessCategory: businessCategory,
      createdAt: DateTime.now(),
      contact: null,
      contactDisplayPreferences: ContactDisplayPreferences(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': id,
      'business_name': businessName,
      'description': description,
      'logo_url': logoUrl,
      'social_links': socialLinks.toJson(),
      'verified': verified,
      'business_category': businessCategory,
      'created_at': createdAt.toIso8601String(),
      'contact_display_preferences': contactDisplayPreferences.toJson(),
      if (contact?.phoneNumber != null) 'phone_number': contact!.phoneNumber,
      if (contact != null) 'contact_info': contact!.toJson(),
    };
  }
}
