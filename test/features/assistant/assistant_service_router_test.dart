import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_service.dart';
import 'package:aplication_tesis/features/assistant/data/assistant_service_router.dart';
import 'package:aplication_tesis/features/assistant/data/gemma_model_service.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// A [GemmaModelService] that always reports the model as NOT installed,
/// avoiding any real flutter_gemma platform calls.
class _FakeModelServiceNotInstalled extends GemmaModelService {
  @override
  Future<bool> isInstalled() async => false;
}

/// A [GemmaModelService] that always reports the model as installed.
class _FakeModelServiceInstalled extends GemmaModelService {
  @override
  Future<bool> isInstalled() async => true;
}

/// An [AssistantService] that throws immediately, simulating a Gemma error.
class _FailingGemmaService implements AssistantService {
  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    throw Exception('Simulated Gemma inference failure');
  }
}

/// An [AssistantService] that yields one token then throws mid-stream.
class _MidStreamFailingGemmaService implements AssistantService {
  _MidStreamFailingGemmaService(this._firstToken);
  final String _firstToken;

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    yield _firstToken;
    throw Exception('Simulated Gemma mid-stream failure');
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssistantServiceRouter', () {
    test(
      'delegates to stub when model is NOT installed',
      () async {
        final router = AssistantServiceRouter(
          stub: StubAssistantService(),
          modelService: _FakeModelServiceNotInstalled(),
          // gemmaFactory is never called when not installed
          gemmaFactory: () => _FailingGemmaService(),
        );

        final result = await router.reply(prompt: 'hola').join();

        // The stub always produces a non-empty canned reply.
        expect(result, isNotEmpty);
        // Confirm it contains stub-specific text.
        expect(result, contains('AvoScan AI'));
      },
    );

    test(
      'falls back to stub when Gemma service throws (model reported installed)',
      () async {
        final router = AssistantServiceRouter(
          stub: StubAssistantService(),
          modelService: _FakeModelServiceInstalled(),
          gemmaFactory: () => _FailingGemmaService(),
        );

        // Should NOT throw — the router catches the Gemma error and uses stub.
        final result = await router.reply(prompt: 'hola').join();

        expect(result, isNotEmpty);
      },
    );

    test(
      'uses Gemma service when installed and no error (fake success service)',
      () async {
        // A simple fake service that yields a known token.
        final fakeGemma = _FakeSuccessGemmaService('Respuesta Gemma');

        final router = AssistantServiceRouter(
          stub: StubAssistantService(),
          modelService: _FakeModelServiceInstalled(),
          gemmaFactory: () => fakeGemma,
        );

        final result = await router.reply(prompt: 'hola').join();

        expect(result, equals('Respuesta Gemma'));
      },
    );

    test(
      'does NOT append stub when Gemma emits a token then throws mid-stream',
      () async {
        final router = AssistantServiceRouter(
          stub: StubAssistantService(),
          modelService: _FakeModelServiceInstalled(),
          gemmaFactory: () => _MidStreamFailingGemmaService('Hola'),
        );

        final result = await router.reply(prompt: 'hola').join();

        // The partial Gemma token must be present.
        expect(result, contains('Hola'));
        // The stub reply must NOT have been appended.
        expect(result, isNot(contains('AvoScan AI')));
      },
    );

    test(
      'reply passes history snapshot to underlying service',
      () async {
        final captureService = _CapturingService();

        final router = AssistantServiceRouter(
          stub: captureService,
          modelService: _FakeModelServiceNotInstalled(),
        );

        final history = [
          AssistantMessage(
            role: AssistantRole.user,
            text: 'primera',
            timestamp: DateTime(2026),
          ),
        ];

        await router
            .reply(prompt: 'segunda', history: history)
            .drain<void>();

        expect(captureService.lastHistory, equals(history));
      },
    );
  });
}

class _FakeSuccessGemmaService implements AssistantService {
  _FakeSuccessGemmaService(this._token);
  final String _token;

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    yield _token;
  }
}

class _CapturingService implements AssistantService {
  List<AssistantMessage> lastHistory = const [];

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    lastHistory = history;
    yield 'ok';
  }
}
