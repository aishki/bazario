class AppNotification {
  final String id;
  final String userId;
  final String orderId;
  final String message;
  final String status;
  final String type;
  bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.message,
    required this.status,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      orderId: json['order_id'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      type:
          json['type'] ??
          'general', // parse type from JSON with default fallback
      read: json['read'] == true || json['read'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'message': message,
      'status': status,
      'type': type, // include type in JSON serialization
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
