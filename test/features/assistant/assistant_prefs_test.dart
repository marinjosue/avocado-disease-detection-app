import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/features/assistant/data/assistant_prefs.dart';
import 'package:aplication_tesis/features/assistant/data/gemma_model_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AssistantPrefs', () {
    test('getToken() returns null when not set', () async {
      final prefs = AssistantPrefs();
      expect(await prefs.getToken(), isNull);
    });

    test('setToken then getToken returns stored value', () async {
      final prefs = AssistantPrefs();
      await prefs.setToken('hf_testtoken123');
      expect(await prefs.getToken(), 'hf_testtoken123');
    });

    test('getModelUrl() returns defaultModelUrl when not set', () async {
      final prefs = AssistantPrefs();
      expect(
        await prefs.getModelUrl(),
        GemmaModelService.defaultModelUrl,
      );
    });

    test('setModelUrl then getModelUrl returns saved value', () async {
      final prefs = AssistantPrefs();
      const customUrl = 'https://example.com/model.litertlm';
      await prefs.setModelUrl(customUrl);
      expect(await prefs.getModelUrl(), customUrl);
    });
  });
}
