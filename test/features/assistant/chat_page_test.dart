import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

Widget _buildTestApp({Widget? home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: ChangeNotifierProvider<AssistantProvider>(
      create: (_) => AssistantProvider(StubAssistantService()),
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
            create: (_) => AssistantProvider(StubAssistantService()),
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
