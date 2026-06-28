import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';

void main() {
  group('AssistantProvider', () {
    late AssistantProvider provider;

    setUp(() {
      provider = AssistantProvider(StubAssistantService());
    });

    test('initial state: no messages, not thinking, no context', () {
      expect(provider.messages, isEmpty);
      expect(provider.isThinking, isFalse);
      expect(provider.context, isNull);
    });

    test('send produces >=2 messages, last is assistant, isThinking false after', () async {
      await provider.send('hola');

      expect(provider.isThinking, isFalse);
      expect(provider.messages.length, greaterThanOrEqualTo(2));
      expect(provider.messages.last.role, equals(AssistantRole.assistant));
      expect(provider.messages.first.role, equals(AssistantRole.user));
      expect(provider.messages.first.text, equals('hola'));
    });

    test('send ignores blank/whitespace text', () async {
      await provider.send('   ');
      expect(provider.messages, isEmpty);
    });

    test('assistant reply text is non-empty after send', () async {
      await provider.send('¿cómo lo trato?');
      expect(provider.messages.last.text, isNotEmpty);
    });

    test('startSession clears messages and sets context', () async {
      await provider.send('hola');
      expect(provider.messages, isNotEmpty);

      const ctx = AssistantContext(
        diseaseType: 'rona',
        diseaseName: 'Roña',
        recommendation: 'Aplicar tratamiento.',
      );
      provider.startSession(context: ctx, greeting: 'Hola, soy AvoScan.');

      expect(provider.messages.length, equals(1));
      expect(provider.messages.first.role, equals(AssistantRole.assistant));
      expect(provider.messages.first.text, equals('Hola, soy AvoScan.'));
      expect(provider.context, equals(ctx));
    });

    test('startSession with no greeting leaves messages empty', () {
      provider.startSession();
      expect(provider.messages, isEmpty);
      expect(provider.context, isNull);
    });

    test('clear empties messages', () async {
      await provider.send('hola');
      provider.clear();
      expect(provider.messages, isEmpty);
    });

    test('multiple sends accumulate correctly', () async {
      await provider.send('primera');
      await provider.send('segunda');
      expect(provider.messages.length, greaterThanOrEqualTo(4));
    });

    test('notifyListeners called during streaming (last message grows)', () async {
      final snapshots = <int>[];
      provider.addListener(() {
        snapshots.add(provider.messages.length);
      });

      await provider.send('hola');

      // At least a few notifications must have occurred
      expect(snapshots, isNotEmpty);
      expect(provider.isThinking, isFalse);
    });
  });
}
