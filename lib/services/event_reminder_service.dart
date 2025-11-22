import 'api_service.dart';
import '../models/event_reminder.dart';

class EventReminderService {
  final ApiService _apiService = ApiService();

  Future<List<EventReminder>> getVendorReminders(String vendorId) async {
    try {
      final response = await _apiService.get(
        'event_reminders.php?vendor_id=$vendorId',
      );

      if (response['success'] == true && response['reminders'] != null) {
        return (response['reminders'] as List)
            .map((r) => EventReminder.fromJson(r))
            .toList();
      }
      return [];
    } catch (e) {
      print('[EventReminder] Error fetching reminders: $e');
      return [];
    }
  }

  Future<bool> createReminder({
    required String vendorId,
    required String eventId,
    required DateTime reminderDatetime,
  }) async {
    try {
      final response = await _apiService.post('event_reminders.php', {
        'action': 'create',
        'vendor_id': vendorId,
        'event_id': eventId,
        'reminder_type': 'custom',
        'reminder_datetime': reminderDatetime.toIso8601String(),
      });

      return response['success'] == true;
    } catch (e) {
      print('[EventReminder] Error creating reminder: $e');
      return false;
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    try {
      final response = await _apiService.post('event_reminders.php', {
        'action': 'delete',
        'id': reminderId,
      });

      if (response == null || response.isEmpty) {
        print('[EventReminder] Empty response from delete');
        return false;
      }

      return response['success'] == true;
    } catch (e) {
      print('[EventReminder] Error deleting reminder: $e');
      return false;
    }
  }

  Future<bool> createAutomaticReminders({
    required String vendorId,
    required String eventId,
    required DateTime eventStart,
  }) async {
    try {
      final response = await _apiService.post('event_reminders.php', {
        'action': 'create_automatic',
        'vendor_id': vendorId,
        'event_id': eventId,
        'event_start': eventStart.toIso8601String(),
      });

      return response['success'] == true;
    } catch (e) {
      print('[EventReminder] Error creating automatic reminders: $e');
      return false;
    }
  }

  Future<bool> markReminderAsNotified(String reminderId) async {
    try {
      final response = await _apiService.post('event_reminders.php', {
        'action': 'mark_notified',
        'id': reminderId,
      });

      return response['success'] == true;
    } catch (e) {
      print('[EventReminder] Error marking as notified: $e');
      return false;
    }
  }
}
