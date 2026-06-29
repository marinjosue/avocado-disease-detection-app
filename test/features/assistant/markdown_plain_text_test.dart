import 'package:flutter_test/flutter_test.dart';

import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';

void main() {
  group('markdownToPlainText', () {
    test('removes bold markers and keeps content', () {
      final result = markdownToPlainText('El cobre **7-10 días** recomendado');
      expect(result, contains('7-10 días'));
      expect(result, isNot(contains('**')));
    });

    test('removes italic asterisk markers', () {
      final result = markdownToPlainText('texto *importante* aquí');
      expect(result, contains('importante'));
      expect(result, isNot(contains('*')));
    });

    test('removes italic underscore markers', () {
      final result = markdownToPlainText('texto _énfasis_ aquí');
      expect(result, contains('énfasis'));
      expect(result, isNot(contains('_')));
    });

    test('removes inline backtick code markers', () {
      final result = markdownToPlainText('usar `comando` aquí');
      expect(result, contains('comando'));
      expect(result, isNot(contains('`')));
    });

    test('removes heading markers', () {
      final result = markdownToPlainText('## Título principal\nContenido');
      expect(result, contains('Título principal'));
      expect(result, isNot(contains('#')));
    });

    test('removes unordered list marker dash', () {
      final result = markdownToPlainText('- uno');
      expect(result, contains('uno'));
      expect(result, isNot(startsWith('-')));
    });

    test('removes unordered list marker asterisk', () {
      final result = markdownToPlainText('* dos');
      expect(result, contains('dos'));
    });

    test('removes ordered list marker', () {
      final result = markdownToPlainText('1. primero\n2. segundo');
      expect(result, contains('primero'));
      expect(result, contains('segundo'));
      expect(result, isNot(contains('1.')));
    });

    test('combined: bold + backtick', () {
      // Mirrors the example from the task spec
      final result = markdownToPlainText('El cobre **7-10 días** y `x`');
      expect(result, contains('7-10 días'));
      expect(result, isNot(contains('**')));
      expect(result, isNot(contains('`')));
    });

    test('plain text is returned unchanged', () {
      const plain = 'Hola esto es texto simple';
      expect(markdownToPlainText(plain), plain);
    });

    test('trims leading and trailing whitespace', () {
      final result = markdownToPlainText('  hola  ');
      expect(result, 'hola');
    });
  });
}
