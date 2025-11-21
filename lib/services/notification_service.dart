import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification.dart';
import '../utils/constants.dart';
import 'local_notification_service.dart';

class NotificationService {
  static const String baseUrl = Constants.apiBaseUrl;
  Timer? _pollTimer;
  final Set<String> _shownNotificationIds = {};

  // This simulates real-time updates by checking the database periodically
  void startNotificationListener(String customerId) {
    // Poll every 5 seconds for new notifications
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkForNotifications(customerId);
    });
  }

  void stopNotificationListener() {
    _pollTimer?.cancel();
  }

  Future<void> _checkForNotifications(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$customerId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['notifications'] != null) {
          for (var notif in data['notifications']) {
            if (notif['read'] == false &&
                !_shownNotificationIds.contains(notif['id'])) {
              await LocalNotificationService.showNotification(
                id: notif['id'].toString().hashCode,
                title: _getNotificationTitle(notif['type']),
                body: notif['message'],
              );
              _shownNotificationIds.add(notif['id']);
              print(
                '[NotificationService] Showed push notification for ${notif['id']}',
              );
            }
          }
        }
      }
    } catch (e) {
      print('[NotificationService] Error checking notifications: $e');
    }
  }

  String _getNotificationTitle(String? type) {
    switch (type) {
      case 'order_update':
        return 'Order Update';
      case 'verification':
        return 'Verification Status';
      case 'event_reminder':
        return 'Event Reminder';
      default:
        return 'Notification';
    }
  }

  Future<List<AppNotification>> getNotifications(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$customerId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<AppNotification> notifications = [];
          for (var notif in data['notifications']) {
            notifications.add(AppNotification.fromJson(notif));
          }
          return notifications;
        }
      }
      return [];
    } catch (e) {
      print('[NotificationService] Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'notification_id': notificationId, 'read': true}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('[NotificationService] Error marking notification as read: $e');
      return false;
    }
  }

  Future<int> getUnreadCount(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$customerId&unread=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['unread_count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print('[NotificationService] Error fetching unread count: $e');
      return 0;
    }
  }
}
