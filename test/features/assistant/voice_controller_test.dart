import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/features/assistant/domain/voice_services.dart';
import 'package:aplication_tesis/features/assistant/data/voice_prefs.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/voice_controller.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeStt implements SpeechToTextService {
  bool _available = true;
  bool _listening = false;

  /// Callbacks installed by startListening so the test can fire them.
  void Function(String partial)? onPartialCb;
  // Stored as dynamic so we can await the Future returned by async closures.
  dynamic onFinalCb;

  int initCallCount = 0;
  int stopCallCount = 0;

  void setAvailable(bool v) => _available = v;

  /// Simulate the engine emitting a partial result.
  void emitPartial(String text) => onPartialCb?.call(text);

  /// Simulate the engine emitting a final result.
  /// Returns a [Future] so tests can `await stt.emitFinal(...)` and let the
  /// async chain inside [VoiceController] fully complete before asserting.
  Future<void> emitFinal(String text) async {
    _listening = false;
    final result = onFinalCb?.call(text);
    if (result is Future) await result;
  }

  @override
  Future<bool> init() async {
    initCallCount++;
    return _available;
  }

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;

  @override
  Future<void> startListening({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    String localeId = 'es_ES',
  }) async {
    _listening = true;
    onPartialCb = onPartial;
    onFinalCb = onFinal; // may be an async closure; stored as dynamic
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    _listening = false;
    onPartialCb = null;
    onFinalCb = null;
  }
}

class _FakeTts implements TtsService {
  void Function(bool speaking)? _cb;

  int initCallCount = 0;
  int stopCallCount = 0;
  final List<String> spokenTexts = [];

  /// Simulate TTS starting to speak.
  void emitStart() => _cb?.call(true);

  /// Simulate TTS finishing (or cancelled).
  void emitStop() => _cb?.call(false);

  @override
  Future<void> init() async {
    initCallCount++;
  }

  @override
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
  }

  @override
  set onSpeakingChanged(void Function(bool speaking) cb) {
    _cb = cb;
  }
}

class _FakeRecorder implements VoiceRecorderService {
  /// Controls what [start] returns.
  bool startResult;

  /// Controls what [stop] returns.
  String? stopPath;

  int startCallCount = 0;
  int stopCallCount = 0;
  int cancelCallCount = 0;

  _FakeRecorder({this.startResult = true, this.stopPath});

  @override
  Future<bool> start() async {
    startCallCount++;
    return startResult;
  }

  @override
  Future<String?> stop() async {
    stopCallCount++;
    return stopPath;
  }

  @override
  Future<void> cancel() async {
    cancelCallCount++;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

VoiceController _makeController({
  _FakeStt? stt,
  _FakeTts? tts,
  VoicePrefs? prefs,
  _FakeRecorder? recorder,
}) {
  return VoiceController(
    stt ?? _FakeStt(),
    tts ?? _FakeTts(),
    prefs ?? VoicePrefs(),
    recorder ?? _FakeRecorder(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VoiceController.init()', () {
    test('loads autoSpeak from prefs (true by default)', () async {
      final vc = _makeController();
      await vc.init();
      expect(vc.autoSpeak, isTrue);
    });

    test('loads autoSpeak = false when prefs stored false', () async {
      SharedPreferences.setMockInitialValues({'assistant_auto_speak': false});
      final vc = _makeController();
      await vc.init();
      expect(vc.autoSpeak, isFalse);
    });

    test('calls stt.init() and tts.init()', () async {
      final stt = _FakeStt();
      final tts = _FakeTts();
      final vc = _makeController(stt: stt, tts: tts);
      await vc.init();
      expect(stt.initCallCount, 1);
      expect(tts.initCallCount, 1);
    });

    test('notifies listeners after init', () async {
      final vc = _makeController();
      int notifyCount = 0;
      vc.addListener(() => notifyCount++);
      await vc.init();
      expect(notifyCount, greaterThan(0));
    });
  });

  group('VoiceController.toggleAutoSpeak()', () {
    test('flips autoSpeak from true to false', () async {
      final vc = _makeController();
      await vc.init();
      expect(vc.autoSpeak, isTrue);
      await vc.toggleAutoSpeak();
      expect(vc.autoSpeak, isFalse);
    });

    test('persists the new value — re-reading VoicePrefs returns new value',
        () async {
      final prefs = VoicePrefs();
      final vc = _makeController(prefs: prefs);
      await vc.init();
      await vc.toggleAutoSpeak(); // true → false
      expect(await prefs.getAutoSpeak(), isFalse);
      await vc.toggleAutoSpeak(); // false → true
      expect(await prefs.getAutoSpeak(), isTrue);
    });

    test('notifies listeners on each toggle', () async {
      final vc = _makeController();
      await vc.init();
      int notifyCount = 0;
      vc.addListener(() => notifyCount++);
      await vc.toggleAutoSpeak();
      expect(notifyCount, greaterThan(0));
    });

    test('stops TTS when toggling autoSpeak OFF while speaking', () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      // Simulate TTS speaking
      tts.emitStart();
      expect(vc.isSpeaking, isTrue);
      // autoSpeak is true; turning it off should stop TTS
      await vc.toggleAutoSpeak();
      expect(tts.stopCallCount, 1);
    });
  });

  group('VoiceController.startDictation()', () {
    test('stops TTS first before starting dictation', () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      expect(tts.stopCallCount, greaterThan(0));
    });

    test('sets isListening = true immediately', () async {
      final stt = _FakeStt();
      final vc = _makeController(stt: stt);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      expect(vc.isListening, isTrue);
    });

    test('updates partialText when STT emits partial', () async {
      final stt = _FakeStt();
      final vc = _makeController(stt: stt);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      stt.emitPartial('hola');
      expect(vc.partialText, 'hola');
    });

    test(
        'when fake STT emits final result, onFinal cb receives text '
        'and isListening returns false', () async {
      final stt = _FakeStt();
      final vc = _makeController(stt: stt);
      await vc.init();

      String? received;
      await vc.startDictation(onFinal: (t, _) => received = t);
      await stt.emitFinal('aguacate sano');

      expect(received, 'aguacate sano');
      expect(vc.isListening, isFalse);
      expect(vc.partialText, '');
    });

    test('notifies listeners on partial and on final', () async {
      final stt = _FakeStt();
      final vc = _makeController(stt: stt);
      await vc.init();
      int notifyCount = 0;
      vc.addListener(() => notifyCount++);
      await vc.startDictation(onFinal: (_, __) {});
      notifyCount = 0; // reset after startDictation notifies
      stt.emitPartial('test');
      expect(notifyCount, greaterThan(0));
      notifyCount = 0;
      await stt.emitFinal('test final');
      expect(notifyCount, greaterThan(0));
    });

    // -------------------------------------------------------------------------
    // Recorder integration tests
    // -------------------------------------------------------------------------

    test('calls recorder.start() when dictation begins', () async {
      final stt = _FakeStt();
      final rec = _FakeRecorder(startResult: true, stopPath: '/tmp/test.m4a');
      final vc = _makeController(stt: stt, recorder: rec);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      expect(rec.startCallCount, 1);
    });

    test(
        'when recorder.start() returns true and STT fires onFinal, '
        'onFinal receives (text, stopPath)', () async {
      final stt = _FakeStt();
      final rec =
          _FakeRecorder(startResult: true, stopPath: '/voice/note.m4a');
      final vc = _makeController(stt: stt, recorder: rec);
      await vc.init();

      String? receivedText;
      String? receivedPath;
      await vc.startDictation(
        onFinal: (t, p) {
          receivedText = t;
          receivedPath = p;
        },
      );
      await stt.emitFinal('hola mundo');

      expect(receivedText, 'hola mundo');
      expect(receivedPath, '/voice/note.m4a');
      expect(rec.stopCallCount, 1);
    });

    test(
        'when recorder.start() returns false, onFinal receives (text, null) '
        'and recorder.stop() is NOT called', () async {
      final stt = _FakeStt();
      final rec = _FakeRecorder(startResult: false, stopPath: '/should/not/appear.m4a');
      final vc = _makeController(stt: stt, recorder: rec);
      await vc.init();

      String? receivedText;
      String? receivedPath = 'sentinel'; // should become null
      await vc.startDictation(
        onFinal: (t, p) {
          receivedText = t;
          receivedPath = p;
        },
      );
      await stt.emitFinal('texto de prueba');

      expect(receivedText, 'texto de prueba');
      expect(receivedPath, isNull);
      expect(rec.stopCallCount, 0); // stop must NOT be called
    });
  });

  group('VoiceController.speak()', () {
    test('delegates to tts.speak()', () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      await vc.speak('Hola mundo');
      expect(tts.spokenTexts, contains('Hola mundo'));
    });

    test('isSpeaking becomes true when fake fires onSpeakingChanged(true)',
        () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      await vc.speak('texto');
      tts.emitStart();
      expect(vc.isSpeaking, isTrue);
    });

    test(
        'isSpeaking becomes false when fake fires onSpeakingChanged(false)',
        () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      await vc.speak('texto');
      tts.emitStart();
      tts.emitStop();
      expect(vc.isSpeaking, isFalse);
    });

    test('notifies listeners when isSpeaking changes', () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      int notifyCount = 0;
      vc.addListener(() => notifyCount++);
      tts.emitStart();
      expect(notifyCount, greaterThan(0));
      notifyCount = 0;
      tts.emitStop();
      expect(notifyCount, greaterThan(0));
    });
  });

  group('VoiceController.stopDictation()', () {
    test('sets isListening false and clears partialText', () async {
      final stt = _FakeStt();
      final vc = _makeController(stt: stt);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      stt.emitPartial('algo');
      await vc.stopDictation();
      expect(vc.isListening, isFalse);
      expect(vc.partialText, '');
    });

    test('calls recorder.cancel() when stopping dictation', () async {
      final stt = _FakeStt();
      final rec = _FakeRecorder(startResult: true);
      final vc = _makeController(stt: stt, recorder: rec);
      await vc.init();
      await vc.startDictation(onFinal: (_, __) {});
      await vc.stopDictation();
      expect(rec.cancelCallCount, 1);
    });
  });

  group('VoiceController.stopSpeaking()', () {
    test('delegates to tts.stop()', () async {
      final tts = _FakeTts();
      final vc = _makeController(tts: tts);
      await vc.init();
      await vc.stopSpeaking();
      expect(tts.stopCallCount, greaterThan(0));
    });
  });
}
