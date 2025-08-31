import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiService.post('auth.php', {
      'action': 'login',
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await _apiService.post('auth.php', {
      'action': 'register',
      ...userData,
    });
  }

  Future<void> logout() async {
    // Clear any stored authentication tokens or user data
    // This can be expanded when implementing token-based authentication
    try {
      // Future: Call logout endpoint if implementing server-side session management
      // await _apiService.post('auth.php', {'action': 'logout'});

      // Clear local storage/preferences here
      print('User logged out successfully');
    } catch (e) {
      print('Logout error: $e');
      // Even if server logout fails, clear local data
    }
  }

  Future<bool> isAuthenticated() async {
    // Future: Implement token validation
    // For now, return false - implement based on your token storage strategy
    return false;
  }

  static bool isLoggedIn() {
    // For now, return false - this will be updated when implementing proper session management
    // Future: Check stored tokens or session data
    return false;
  }
}
