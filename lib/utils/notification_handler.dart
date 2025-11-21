import 'package:flutter/material.dart';

class NotificationHandler {
  static void handleNotificationTap(
    BuildContext context,
    String? notificationType,
  ) {
    if (notificationType == 'event_reminder' ||
        notificationType == 'order_update') {
      // Navigate to notifications screen
      Navigator.of(context).pushNamed('/notifications');
    }
  }
}
