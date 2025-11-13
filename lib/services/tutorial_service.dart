import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static final Map<String, bool> _sessionTutorials = {};

  // Check if tutorial has been shown in current session
  static Future<bool> hasSeenTutorial(String tutorialId) async {
    // First check if it's been shown in this session
    if (_sessionTutorials.containsKey(tutorialId)) {
      return _sessionTutorials[tutorialId] ?? false;
    }

    // If not in session, check persistent storage for user preference
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'tutorial_disabled_$tutorialId';
      final isDisabled = prefs.getBool(key) ?? false;
      return isDisabled;
    } catch (e) {
      return false;
    }
  }

  // Mark tutorial as seen in current session
  static Future<void> setHasSeenTutorial(String tutorialId, bool value) async {
    // Always mark as seen in current session
    _sessionTutorials[tutorialId] = value;

    // If user wants to disable permanently, save to persistent storage
    if (value) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = 'tutorial_disabled_$tutorialId';
        await prefs.setBool(key, true);
      } catch (e) {
        // Silently fail if SharedPreferences is unavailable
      }
    }
  }

  // Reset all tutorials for new session (call on logout)
  static void resetSessionTutorials() {
    _sessionTutorials.clear();
  }

  // Reset specific tutorial for new session
  static void resetTutorial(String tutorialId) {
    _sessionTutorials.remove(tutorialId);
  }
}
