import 'package:shared_preferences/shared_preferences.dart';

/// Persists voice-related user preferences to SharedPreferences.
///
/// Keys used:
///   'assistant_auto_speak' — whether the assistant reads replies aloud (default: true)
class VoicePrefs {
  static const String _key = 'assistant_auto_speak';

  Future<bool> getAutoSpeak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setAutoSpeak(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
