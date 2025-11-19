class Announcement {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  int likes;
  final String adminName; // NEW: admin username
  bool isLiked; // NEW: track if current vendor liked it

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.likes,
    required this.adminName,
    this.isLiked = false, // default to false
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '', // ensure string
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(), // fallback if null
      likes: json['likes'] != null
          ? int.tryParse(json['likes'].toString()) ?? 0
          : 0,
      adminName: json['admin_name']?.toString() ?? 'Admin', // safe fallback
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    'likes': likes,
    'admin_name': adminName,
    'is_liked': isLiked,
  };
}
