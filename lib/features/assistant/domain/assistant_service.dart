import 'assistant_context.dart';
import 'assistant_message.dart';

abstract class AssistantService {
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  });
}
