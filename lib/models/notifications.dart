class AppNotification {
  final String id;
  final String customerId;
  final String orderId;
  final String title;
  final String message;
  final String status;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.customerId,
    required this.orderId,
    required this.title,
    required this.message,
    required this.status,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      orderId: json['order_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_id': orderId,
      'title': title,
      'message': message,
      'status': status,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
