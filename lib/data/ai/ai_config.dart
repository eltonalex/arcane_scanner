import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_identifier.dart';
import 'anthropic_identifier.dart';
import 'gemini_identifier.dart';
import 'openai_identifier.dart';

enum AiProvider {
  openai('OpenAI (gpt-4o-mini)'),
  gemini('Google Gemini (2.5 Flash)'),
  anthropic('Anthropic Claude (Sonnet 4.5)');

  const AiProvider(this.label);
  final String label;

  String get storageKey => 'ai_api_key_$name';
}

/// Config do fallback de IA.
/// - Provedor selecionado: SharedPreferences (não é segredo).
/// - Chave da API: flutter_secure_storage (Keystore/Keychain) — nunca
///   logar, nunca gravar em prefs.
class AiConfigRepository {
  AiConfigRepository({FlutterSecureStorage? storage})
      : _secure = storage ?? const FlutterSecureStorage();

  static const _providerPref = 'ai_provider';
  final FlutterSecureStorage _secure;

  Future<AiProvider> selectedProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_providerPref);
    return AiProvider.values.firstWhere(
      (p) => p.name == name,
      orElse: () => AiProvider.openai,
    );
  }

  Future<void> setSelectedProvider(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerPref, provider.name);
  }

  Future<String?> apiKeyFor(AiProvider provider) =>
      _secure.read(key: provider.storageKey);

  Future<void> setApiKey(AiProvider provider, String key) => key.isEmpty
      ? _secure.delete(key: provider.storageKey)
      : _secure.write(key: provider.storageKey, value: key);

  /// Monta o identificador do provedor selecionado, ou null se não
  /// houver chave configurada (o pipeline então fica só com o OCR).
  Future<AiCardIdentifier?> buildIdentifier() async {
    final provider = await selectedProvider();
    final key = await apiKeyFor(provider);
    if (key == null || key.isEmpty) return null;
    return switch (provider) {
      AiProvider.openai => OpenAiIdentifier(apiKey: key),
      AiProvider.gemini => GeminiIdentifier(apiKey: key),
      AiProvider.anthropic => AnthropicIdentifier(apiKey: key),
    };
  }
}
