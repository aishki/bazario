import '../models/event.dart';
import 'api_service.dart';

class EventService {
  final ApiService _api = ApiService();

  Future<List<Event>> fetchEvents({String? type, String? vendorId}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (vendorId != null) queryParams['vendor_id'] = vendorId;

      final queryString = queryParams.isNotEmpty
          ? '?' +
                queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';

      final response = await _api.get('events.php$queryString');

      if (response['success'] == true && response['events'] != null) {
        return (response['events'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('[EventService] Error fetching events: $e');
      return [];
    }
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await _api.get('events.php?event_id=$eventId');
      if (response['success'] == true && response['event'] != null) {
        return Event.fromJson(response['event']);
      }
      return null;
    } catch (e) {
      print('[EventService] Error fetching event by ID: $e');
      return null;
    }
  }

  Future<bool> createEvent(Event event) async {
    try {
      final response = await _api.post("events.php", event.toJson());
      return response['success'] == true;
    } catch (e) {
      print('[EventService] Error creating event: $e');
      return false;
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      final response = await _api.put("events.php", event.toJson());
      return response['success'] == true;
    } catch (e) {
      print('[EventService] Error updating event: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      final response = await _api.delete("events.php", {"id": eventId});
      return response['success'] == true;
    } catch (e) {
      print('[EventService] Error deleting event: $e');
      return false;
    }
  }

  Future<bool> applyAsVendor({
    required String eventId,
    required String vendorId,
  }) async {
    try {
      final response = await _api.post("event_vendors.php", {
        "event_id": eventId,
        "vendor_id": vendorId,
        "status": "applied",
      });
      return response['success'] == true;
    } catch (e) {
      print('[EventService] Error applying as vendor: $e');
      return false;
    }
  }
}
