import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/announcement.dart';
import '../utils/constants.dart';

class AnnouncementService {
  static const String baseUrl = Constants.apiBaseUrl;
  Timer? _pollTimer;

  // Poll announcements every 10 seconds (simulates live updates)
  void startAnnouncementListener(String vendorId) {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _checkForAnnouncements(vendorId);
    });
  }

  void stopAnnouncementListener() {
    _pollTimer?.cancel();
  }

  Future<void> _checkForAnnouncements(String vendorId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/announcements.php?target=vendors&vendor_id=$vendorId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // announcements fetched, can notify UI using state management if needed
        }
      }
    } catch (e) {
      print('[AnnouncementService] Error checking announcements: $e');
    }
  }

  Future<List<Announcement>> getVendorAnnouncements(String vendorId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/announcements.php?target=vendors&vendor_id=$vendorId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('[AnnouncementService] Raw JSON: ${data['announcements']}');
          List<Announcement> announcements = [];
          for (var ann in data['announcements']) {
            announcements.add(Announcement.fromJson(ann));
          }
          return announcements;
        }
      }
      return [];
    } catch (e) {
      print('[AnnouncementService] Error fetching announcements: $e');
      return [];
    }
  }

  /// Handles both like and unlike actions
  Future<bool> likeAnnouncement(
    String announcementId,
    String userId,
    bool isLiked,
  ) async {
    try {
      final action = isLiked
          ? 'like'
          : 'unlike'; // if true, like; if false, unlike

      final response = await http.post(
        Uri.parse('$baseUrl/announcements.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'announcement_id': announcementId,
          'user_id': userId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('[AnnouncementService] Error toggling announcement like: $e');
      return false;
    }
  }
}
