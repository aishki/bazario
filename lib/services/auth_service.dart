import 'api_service.dart';
import 'tutorial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _vendorIdKey = 'vendor_id';
  static const String _businessNameKey = 'business_name';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post('auth.php', {
      'action': 'login',
      'email': email,
      'password': password,
    });

    if (response['success'] == true && response['user'] != null) {
      await storeUserSession(response['user']);
    }

    return response;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await _apiService.post('auth.php', {
      'action': 'register',
      ...userData,
    });
  }

  Future<void> storeUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user['id'] ?? '');
    await prefs.setString(_userRoleKey, user['role'] ?? '');
    await prefs.setString(_vendorIdKey, user['vendor_id'] ?? '');
    await prefs.setString(_businessNameKey, user['business_name'] ?? '');
    await prefs.setBool(_isLoggedInKey, true);

    print('[v0] User session stored successfully');
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    return {
      'id': prefs.getString(_userIdKey) ?? '',
      'role': prefs.getString(_userRoleKey) ?? '',
      'vendor_id': prefs.getString(_vendorIdKey) ?? '',
      'business_name': prefs.getString(_businessNameKey) ?? '',
    };
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_vendorIdKey);
      await prefs.remove(_businessNameKey);
      await prefs.setBool(_isLoggedInKey, false);

      TutorialService.resetSessionTutorials();

      print('[v0] User session cleared successfully');
    } catch (e) {
      print('[v0] Logout error: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _apiService.post('auth.php', {
        'action': 'check_username',
        'username': username,
      });

      return response['available'] == true;
    } catch (e) {
      print('[AuthService] Username check error: $e');
      return false; // treat as unavailable if error
    }
  }

  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _apiService.post('auth.php', {
        'action': 'check_email',
        'email': email,
      });

      return response['available'] == true;
    } catch (e) {
      print('[AuthService] Email check error: $e');
      return false;
    }
  }

  Future<bool> checkPhoneAvailability(String phone) async {
    try {
      final response = await _apiService.post('auth.php', {
        'action': 'check_phone',
        'phone': phone,
      });

      return response['available'] == true;
    } catch (e) {
      print('[AuthService] Phone check error: $e');
      return false;
    }
  }
}
