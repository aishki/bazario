import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service for checking availability of username, email, and phone
/// Handles API calls to backend for real-time validation
class AvailabilityCheckService {
  /// Checks if username is available
  /// Returns null if available, error message if taken
  static Future<String?> checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      return "Username is required";
    }

    try {
      final response = await http.post(
        Uri.parse("${Constants.apiBaseUrl}/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_username", "username": username}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        return "This username isn't available. Please try another.";
      }

      return null; // Username is available
    } catch (e) {
      print("[v0] Error checking username availability: $e");
      return "Unable to verify username availability";
    }
  }

  /// Checks if email is available
  /// Returns null if available, error message if taken
  static Future<String?> checkEmailAvailability(String email) async {
    if (email.isEmpty) {
      return "Email is required";
    }

    try {
      final response = await http.post(
        Uri.parse("${Constants.apiBaseUrl}/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_email", "email": email}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        return "This email isn't available. Please try another.";
      }

      return null; // Email is available
    } catch (e) {
      print("[v0] Error checking email availability: $e");
      return "Unable to verify email availability";
    }
  }

  /// Checks if phone number is available
  /// Returns null if available, error message if taken
  static Future<String?> checkPhoneAvailability(String phone) async {
    if (phone.isEmpty) {
      return "Phone number is required";
    }

    try {
      final response = await http.post(
        Uri.parse("${Constants.apiBaseUrl}/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_phone", "phone": phone}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        return "This phone number isn't available. Please try another.";
      }

      return null; // Phone is available
    } catch (e) {
      print("[v0] Error checking phone availability: $e");
      return "Unable to verify phone availability";
    }
  }
}
