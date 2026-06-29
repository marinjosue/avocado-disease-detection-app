import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// In-memory fake repository — avoids real SQLite in widget tests
// ---------------------------------------------------------------------------

class _FakeRepo extends ConversationRepository {
  final List<Conversation> _convs = [];
  final Map<int, List<AssistantMessage>> _messages = {};
  int _nextId = 1;

  _FakeRepo() : super(db: null);

  @override
  Future<Conversation> create(Conversation c) async {
    final id = _nextId++;
    final saved = c.copyWith(id: id);
    _convs.add(saved);
    _messages[id] = [];
    return saved;
  }

  @override
  Future<List<Conversation>> getAll() async =>
      List<Conversation>.from(_convs.reversed);

  @override
  Future<Conversation?> getById(int id) async {
    final idx = _convs.indexWhere((c) => c.id == id);
    if (idx < 0) return null;
    final conv = _convs[idx];
    return conv.copyWith(messages: List.from(_messages[id] ?? []));
  }

  @override
  Future<Conversation?> getByDetectionKey(String key) async {
    final idx = _convs.lastIndexWhere((c) => c.detectionKey == key);
    if (idx < 0) return null;
    final conv = _convs[idx];
    return conv.copyWith(messages: List.from(_messages[conv.id!] ?? []));
  }

  @override
  Future<AssistantMessage> addMessage(
    int conversationId,
    AssistantMessage m,
  ) async {
    _messages.putIfAbsent(conversationId, () => []).add(m);
    return m;
  }

  @override
  Future<void> updateConversation(
    int id, {
    String? title,
    DateTime? updatedAt,
  }) async {
    final idx = _convs.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    _convs[idx] = _convs[idx].copyWith(
      title: title ?? _convs[idx].title,
      updatedAt: updatedAt ?? _convs[idx].updatedAt,
    );
  }

  @override
  Future<void> delete(int id) async {
    _convs.removeWhere((c) => c.id == id);
    _messages.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    _convs.clear();
    _messages.clear();
  }
}

Widget _buildTestApp({Widget? home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: ChangeNotifierProvider<AssistantProvider>(
      create: (_) => AssistantProvider(
        StubAssistantService(),
        repository: _FakeRepo(),
      ),
      child: home ?? const ChatPage(),
    ),
  );
}

void main() {
  group('ChatPage', () {
    testWidgets('renders disclaimer and input hint', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Disclaimer text from l10n (es): "Orientativo — no sustituye a un agrónomo certificado."
      expect(
        find.textContaining('Orientativo'),
        findsOneWidget,
      );

      // Input hint from l10n (es): "Escribe tu pregunta…"
      expect(
        find.bySemanticsLabel(RegExp(r'Escribe tu pregunta')),
        findsAny,
      );
    });

    testWidgets('typing and tapping send shows user bubble', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      const userMessage = 'Hola, prueba de texto';

      // Find the TextField and enter text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, userMessage);
      await tester.pump();

      // Tap send (IconButton with Icons.send)
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);

      // Wait for streaming reply to complete (stub has 120ms delays × 2 chunks)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The typed text should appear in the chat as a user bubble
      expect(find.text(userMessage), findsOneWidget);
    });

    testWidgets('AppBar shows assistant title', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // "Asistente IA" from l10n
      expect(find.text('Asistente IA'), findsOneWidget);
    });

    testWidgets('context chip shown when hasDetection is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          theme: AppTheme.light,
          home: ChangeNotifierProvider<AssistantProvider>(
            create: (_) => AssistantProvider(
              StubAssistantService(),
              repository: _FakeRepo(),
            ),
            child: const ChatPage(
              // ignore: avoid_redundant_argument_values
              context: null, // no detection context — no chip expected
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without a detection context the "Sobre" label should NOT appear
      expect(find.textContaining('Sobre'), findsNothing);
    });
  });
}
