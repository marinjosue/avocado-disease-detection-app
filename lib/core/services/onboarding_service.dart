import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has already seen the onboarding flow.
///
/// Key: `'onboarding_seen'` (bool, defaults to false when absent).
class OnboardingService {
  static const String _key = 'onboarding_seen';

  /// Returns `true` if the user has already completed or skipped onboarding.
  Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as seen.
  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Resets the flag so onboarding will show again on next launch.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
