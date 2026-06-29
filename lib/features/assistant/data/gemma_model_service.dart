import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Service responsible for checking and downloading the on-device Gemma model.
class GemmaModelService {
  static const String defaultModelUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.litertlm';

  static const String modelFileName = 'gemma3-1b-it-int4.litertlm';

  /// Returns true if the model file is already installed on this device.
  Future<bool> isInstalled() {
    return FlutterGemma.isModelInstalled(modelFileName);
  }

  /// Downloads and installs the model from [url].
  ///
  /// [token] is an optional HuggingFace token entered by the user at runtime.
  /// If [token] is null, empty, or whitespace it is NOT forwarded (pass null).
  /// [onProgress] receives integer progress values in the range 0..100.
  Future<void> download({
    required String url,
    String? token,
    required void Function(int progress) onProgress,
  }) async {
    final String? effectiveToken =
        (token == null || token.trim().isEmpty) ? null : token;

    await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
          fileType: ModelFileType.litertlm,
        )
        .fromNetwork(url, token: effectiveToken)
        .withProgress((int p) => onProgress(p))
        .install();
  }

  /// Re-registers the already-downloaded model file as the active model
  /// WITHOUT re-downloading it (install() is idempotent — skips the network
  /// fetch when the file already exists).
  ///
  /// Call this at the start of each inference session to ensure the active
  /// model identity is set, even after a cold app restart cleared it from
  /// memory.
  Future<void> ensureActive({
    required String url,
    String? token,
  }) async {
    debugPrint('[GemmaAI] ensureActive: start (url=$url)');
    final String? effectiveToken =
        (token == null || token.trim().isEmpty) ? null : token;

    await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
          fileType: ModelFileType.litertlm,
        )
        .fromNetwork(url, token: effectiveToken)
        .install();
    debugPrint('[GemmaAI] ensureActive: done');
  }
}
