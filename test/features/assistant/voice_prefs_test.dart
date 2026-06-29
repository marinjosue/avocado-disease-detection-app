import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/features/assistant/data/voice_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VoicePrefs', () {
    test('(a) default getAutoSpeak() returns true', () async {
      final prefs = VoicePrefs();
      expect(await prefs.getAutoSpeak(), isTrue);
    });

    test('(b) after setAutoSpeak(false), getAutoSpeak() returns false', () async {
      final prefs = VoicePrefs();
      await prefs.setAutoSpeak(false);
      expect(await prefs.getAutoSpeak(), isFalse);
    });

    test('(c) after setAutoSpeak(true), getAutoSpeak() returns true', () async {
      final prefs = VoicePrefs();
      await prefs.setAutoSpeak(false);
      await prefs.setAutoSpeak(true);
      expect(await prefs.getAutoSpeak(), isTrue);
    });
  });
}
