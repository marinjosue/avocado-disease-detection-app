import 'package:shared_preferences/shared_preferences.dart';

import 'ai_access_config.dart';

/// Persists whether the user has unlocked the on-device AI features via the
/// exclusive access code (see [kAiAccessCode]).
///
/// Keys used:
///   'ai_unlocked' — bool, whether the access code was ever accepted (default: false)
class AiAccessPrefs {
  static const String _unlockedKey = 'ai_unlocked';

  /// Whether the AI features are unlocked on this device. Defaults to false.
  Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlockedKey) ?? false;
  }

  Future<void> setUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockedKey, value);
  }

  /// Attempts to unlock with [code]. If it matches [kAiAccessCode] (after
  /// trimming), persists the unlocked state and returns `true`. Otherwise
  /// leaves the persisted state untouched and returns `false`.
  Future<bool> tryUnlock(String code) async {
    if (code.trim() == kAiAccessCode) {
      await setUnlocked(true);
      return true;
    }
    return false;
  }
}
