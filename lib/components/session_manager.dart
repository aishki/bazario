import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyRole = 'role';

  static Future<void> saveSession({
    required String userId,
    required String username,
    required String customerId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyCustomerId, customerId);
    await prefs.setString(_keyRole, role);
  }

  static Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString(_keyUserId),
      'username': prefs.getString(_keyUsername),
      'customer_id': prefs.getString(_keyCustomerId),
      'role': prefs.getString(_keyRole),
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }
}
