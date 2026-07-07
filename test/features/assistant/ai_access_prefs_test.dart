import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/features/assistant/data/ai_access_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiAccessPrefs', () {
    test('isUnlocked defaults to false', () async {
      expect(await AiAccessPrefs().isUnlocked(), isFalse);
    });

    test('tryUnlock with a wrong code returns false and stays locked',
        () async {
      final prefs = AiAccessPrefs();
      expect(await prefs.tryUnlock('0000'), isFalse);
      expect(await prefs.isUnlocked(), isFalse);
    });

    test('tryUnlock with the correct code returns true and persists',
        () async {
      final prefs = AiAccessPrefs();
      expect(await prefs.tryUnlock('2002'), isTrue);
      expect(await prefs.isUnlocked(), isTrue);
      // A fresh instance reads the same persisted state.
      expect(await AiAccessPrefs().isUnlocked(), isTrue);
    });

    test('tryUnlock trims surrounding whitespace', () async {
      final prefs = AiAccessPrefs();
      expect(await prefs.tryUnlock('  2002  '), isTrue);
      expect(await prefs.isUnlocked(), isTrue);
    });

    test('setUnlocked(false) re-locks', () async {
      final prefs = AiAccessPrefs();
      await prefs.setUnlocked(true);
      await prefs.setUnlocked(false);
      expect(await prefs.isUnlocked(), isFalse);
    });
  });
}
