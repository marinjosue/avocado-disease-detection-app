import 'package:shared_preferences/shared_preferences.dart';
import 'gemma_model_service.dart';

/// Persists assistant-related user preferences to SharedPreferences.
///
/// Keys used:
///   'assistant_hf_token'  — optional HuggingFace token (set by user at runtime)
///   'assistant_model_url' — model download URL (defaults to [GemmaModelService.defaultModelUrl])
class AssistantPrefs {
  static const String _tokenKey = 'assistant_hf_token';
  static const String _modelUrlKey = 'assistant_model_url';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String> getModelUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelUrlKey) ?? GemmaModelService.defaultModelUrl;
  }

  Future<void> setModelUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelUrlKey, url);
  }
}
