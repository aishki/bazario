import 'package:flutter/material.dart';
import 'event_reminder_service.dart';
import 'local_notification_service.dart';
import 'auth_service.dart';
import 'dart:async';

class ReminderSchedulerService {
  static final ReminderSchedulerService _instance =
      ReminderSchedulerService._internal();
  Timer? _timer;
  final EventReminderService _reminderService = EventReminderService();
  final AuthService _authService = AuthService();

  ReminderSchedulerService._internal();

  factory ReminderSchedulerService() {
    return _instance;
  }

  void startReminderChecker() {
    debugPrint('[ReminderScheduler] Starting reminder checker');

    // Check immediately on start
    _checkAndScheduleReminders();

    // Then check every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAndScheduleReminders();
    });
  }

  Future<void> _checkAndScheduleReminders() async {
    try {
      final session = await _authService.getUserSession();
      if (session == null || session['vendor_id'] == null) return;

      final vendorId = session['vendor_id'] as String;
      final reminders = await _reminderService.getVendorReminders(vendorId);

      final now = DateTime.now();

      for (var reminder in reminders) {
        if (!reminder.isNotified &&
            reminder.reminderDatetime.isBefore(
              now.add(const Duration(minutes: 1)),
            )) {
          final timeDiff = reminder.reminderDatetime.difference(now).inSeconds;

          if (timeDiff <= 0) {
            // Schedule immediately if already past
            await LocalNotificationService.showNotification(
              id: reminder.id.hashCode,
              title: '${reminder.eventName} Reminder',
              body: '${reminder.eventName} is happening now!',
            );

            // Mark as notified
            await _reminderService.markReminderAsNotified(reminder.id);
            debugPrint(
              '[ReminderScheduler] Showed notification for ${reminder.eventName}',
            );
          } else {
            // Schedule for future time
            await LocalNotificationService.scheduleNotification(
              id: reminder.id.hashCode,
              title: '${reminder.eventName} Reminder',
              body: '${reminder.eventName} is coming up!',
              scheduledTime: reminder.reminderDatetime,
            );
            debugPrint(
              '[ReminderScheduler] Scheduled notification for ${reminder.eventName} in ${timeDiff}s',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[ReminderScheduler] Error checking reminders: $e');
    }
  }

  void stopReminderChecker() {
    _timer?.cancel();
    debugPrint('[ReminderScheduler] Stopped reminder checker');
  }
}
