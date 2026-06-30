import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../domain/voice_services.dart';

/// Concrete [VoiceRecorderService] that uses the `record` package to capture
/// audio alongside a dictation session.
///
/// All operations are best-effort: every public method swallows exceptions and
/// returns a safe fallback so callers never need to guard against failures here.
class RealVoiceRecorderService implements VoiceRecorderService {
  final AudioRecorder _rec = AudioRecorder();

  /// The file path passed to [_rec.start], kept so [stop] can return it even
  /// if the plugin forgets it.
  String? _currentPath;

  @override
  Future<bool> start() async {
    try {
      if (!await _rec.hasPermission()) return false;

      final appDocsDir = await getApplicationDocumentsDirectory();
      final voiceNotesDir = Directory('${appDocsDir.path}/voice_notes');
      await voiceNotesDir.create(recursive: true);

      final path =
          '${voiceNotesDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _rec.start(const RecordConfig(), path: path);
      _currentPath = path;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> stop() async {
    try {
      final pluginPath = await _rec.stop();
      final result = pluginPath ?? _currentPath;
      _currentPath = null;
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _rec.cancel();
    } catch (_) {
      // ignore
    }
    _currentPath = null;
  }
}
