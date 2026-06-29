import 'package:flutter_gemma/flutter_gemma.dart';

import '../domain/assistant_context.dart';
import '../domain/assistant_message.dart';
import '../domain/assistant_service.dart';

/// On-device inference via flutter_gemma (Gemma 3 1B-IT).
///
/// The [InferenceModel] is loaded lazily and CACHED — created once on the first
/// [reply] call and reused across subsequent calls. A FRESH [InferenceChat] is
/// created per reply so the model's KV cache never bleeds between turns.
///
/// Call [dispose] when the service is no longer needed to release native memory.
class GemmaAssistantService implements AssistantService {
  static const _systemInstruction =
      'Eres el asistente de avocadoIA, un agrónomo conciso. '
      'Responde en español, breve y claro, sobre enfermedades del aguacate '
      '(Mancha Negra, Roña) y su manejo. '
      'Si hay contexto del análisis, úsalo. '
      'Cierra recordando que es orientativo y no sustituye a un agrónomo certificado.';

  InferenceModel? _cachedModel;

  Future<InferenceModel> _getModel() async {
    _cachedModel ??= await FlutterGemma.getActiveModel(
      maxTokens: 1024,
      preferredBackend: PreferredBackend.gpu,
    );
    return _cachedModel!;
  }

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    // Build a single full prompt that includes system instruction, optional
    // grounding context, the last ≤4 history pairs, and the new user message.
    final buffer = StringBuffer();
    buffer.writeln(_systemInstruction);

    if (context != null) {
      final grounding = context.toGroundingText();
      if (grounding.isNotEmpty) {
        buffer.writeln(grounding);
      }
    }

    // Append up to last 4 history messages as formatted context.
    final recentHistory = history.length > 4
        ? history.sublist(history.length - 4)
        : history;
    for (final msg in recentHistory) {
      if (msg.role == AssistantRole.user) {
        buffer.writeln('Usuario: ${msg.text}');
      } else {
        buffer.writeln('Asistente: ${msg.text}');
      }
    }

    buffer.write('Usuario: $prompt\nAsistente:');

    final fullPrompt = buffer.toString();

    final model = await _getModel();
    // Fresh chat per reply — model weights are cached, KV cache is not.
    final chat = await model.createChat(temperature: 0.3);
    await chat.addQueryChunk(Message.text(text: fullPrompt, isUser: true));

    await for (final response in chat.generateChatResponseAsync()) {
      if (response is TextResponse) {
        yield response.token;
      }
    }
  }

  /// Closes the cached model and releases native resources.
  Future<void> dispose() async {
    final model = _cachedModel;
    _cachedModel = null;
    await model?.close();
  }
}
