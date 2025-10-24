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

  factory SocialLinks.empty() {
    return SocialLinks(
      facebook: '',
      instagram: '',
      twitter: '',
      website: '',
      tiktok: '',
      youtube: '',
    );
  }

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

  factory ContactDisplayPreferences.empty() {
    return ContactDisplayPreferences(
      showInstagram: true,
      showFacebook: true,
      showPhone: true,
      showWebsite: false,
      showTiktok: false,
      showTwitter: false,
    );
  }

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

  // 🆕 Getter methods to access contact fields directly
  String? get firstName => contact?.firstName;
  String? get lastName => contact?.lastName;
  String? get suffix => contact?.suffix;
  String? get phoneNumber => contact?.phoneNumber;
  String? get email => contact?.email;
  String? get position => contact?.position;
  DateTime? get contactCreatedAt => contact?.createdAt;

  String get fullName => contact?.fullName ?? '';

  factory Vendor.empty() {
    return Vendor(
      id: '',
      businessName: 'My Business',
      description: '',
      logoUrl: '',
      socialLinks: SocialLinks.empty(),
      verified: false,
      businessCategory: '',
      createdAt: DateTime.now(),
      contact: null, // or VendorContact.empty() if you add one
      contactDisplayPreferences: ContactDisplayPreferences.empty(),
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('vendor') ? json['vendor'] : json;

    print("[DEBUG] Vendor.fromJson data: $data");

    VendorContact? contact;

    if (data['contact'] != null) {
      contact = VendorContact.fromJson(data['contact']);
    } else if (data['phone_number'] != null ||
        data['contact_email'] != null ||
        data['position'] != null) {
      contact = VendorContact(
        phoneNumber: data['phone_number'],
        email: data['contact_email'] ?? data['email'],
        position: data['position'],
      );
    }

    return Vendor(
      id: data['vendor_id'] ?? data['id'] ?? '',
      businessName: data['business_name'] ?? 'Unknown',
      description: data['description'],
      logoUrl: data['logo_url'],
      socialLinks: SocialLinks.fromJson(data['social_links'] ?? {}),
      verified: data['verified'] == true || data['verified'] == 1,
      businessCategory: data['business_category'],
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      contact: contact,
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
      if (contact != null) 'contact': contact!.toJson(),
    };
  }
}
