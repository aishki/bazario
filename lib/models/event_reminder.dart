import 'package:intl/intl.dart';

class EventReminder {
  final String id;
  final String vendorId;
  final String eventId;
  final String reminderType;
  final DateTime reminderDatetime;
  final bool isNotified;
  final DateTime createdAt;
  final String? eventName; // Added for display

  EventReminder({
    required this.id,
    required this.vendorId,
    required this.eventId,
    required this.reminderType,
    required this.reminderDatetime,
    this.isNotified = false,
    required this.createdAt,
    this.eventName,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'],
      vendorId: json['vendor_id'],
      eventId: json['event_id'],
      reminderType: json['reminder_type'],
      reminderDatetime: DateTime.parse(json['reminder_datetime']),
      isNotified: json['is_notified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      eventName: json['event_name'],
    );
  }

  String get displayLabel {
    switch (reminderType) {
      case '1_month':
        return '1 Month Before';
      case '1_week':
        return '1 Week Before';
      case '1_day':
        return '1 Day Before';
      case '1_hour':
        return '1 Hour Before';
      case 'custom':
        return DateFormat('MMM d, yyyy h:mm a').format(reminderDatetime);
      default:
        return reminderType;
    }
  }

  String get timeUntilReminder {
    final now = DateTime.now();
    final diff = reminderDatetime.difference(now);

    if (diff.inSeconds < 0) return 'Passed';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
