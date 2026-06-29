import '../domain/assistant_context.dart';
import '../domain/assistant_message.dart';
import '../domain/assistant_service.dart';
import 'gemma_assistant_service.dart';
import 'gemma_model_service.dart';
import 'stub_assistant_service.dart';

/// Routes inference to [GemmaAssistantService] when the on-device model is
/// installed, and falls back to [StubAssistantService] otherwise (or on any
/// error during loading / inference).
///
/// Constructor accepts injected collaborators so tests can supply fakes without
/// touching the real flutter_gemma implementation.
class AssistantServiceRouter implements AssistantService {
  AssistantServiceRouter({
    AssistantService? stub,
    GemmaModelService? modelService,
    AssistantService Function()? gemmaFactory,
  })  : _stub = stub ?? StubAssistantService(),
        _modelService = modelService ?? GemmaModelService(),
        _gemmaFactory = gemmaFactory ?? (() => GemmaAssistantService());

  final AssistantService _stub;
  final GemmaModelService _modelService;
  final AssistantService Function() _gemmaFactory;

  AssistantService? _gemma;

  AssistantService _getGemma() {
    _gemma ??= _gemmaFactory();
    return _gemma!;
  }

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    final installed = await _modelService.isInstalled();
    if (!installed) {
      yield* _stub.reply(prompt: prompt, context: context, history: history);
      return;
    }

    // Model is installed — try Gemma, fall back to stub ONLY if it fails
    // before emitting any token (avoids garbled double-answer on mid-stream error).
    var emitted = false;
    try {
      await for (final token in _getGemma().reply(
        prompt: prompt,
        context: context,
        history: history,
      )) {
        emitted = true;
        yield token;
      }
    } catch (_) {
      if (!emitted) {
        yield* _stub.reply(prompt: prompt, context: context, history: history);
      }
      // if tokens were already emitted, stop here — do NOT append the stub
    }
  }
}
