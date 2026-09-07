import 'dart:convert';
import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/models/card_identification.dart';

/// Interface dos provedores de IA multimodal (OpenAI, Gemini, Anthropic).
/// Implementações fazem chamada REST direta via dio.
abstract interface class AiCardIdentifier {
  Future<Result<CardIdentification>> identify(Uint8List jpegBytes);
}

/// Prompt de sistema — idêntico ao do app React original.
const aiSystemPrompt =
    'Você é um especialista em identificação de cartas de Magic: The '
    'Gathering. Analise a imagem da carta e retorne APENAS um objeto JSON '
    'válido (sem markdown, sem texto extra) no formato: '
    '{"name": "...", "set": "...", "collector_number": "...", '
    '"confidence": 0..1, "notes": "..."}. Prefira nome em inglês. '
    'Se não conseguir ler o set ou collector_number, use "" e diminua a '
    'confidence. Não invente valores.';

/// Converte a resposta textual do modelo (possivelmente com cercas de
/// markdown, apesar do prompt) na identificação estruturada.
Result<CardIdentification> parseAiResponse(String rawText) {
  try {
    var text = rawText.trim();
    // Remove cercas ```json ... ``` caso o modelo desobedeça o prompt.
    final fenced =
        RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (fenced != null) text = fenced.group(1)!.trim();
    // Última defesa: recorta do primeiro { ao último }.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end <= start) {
      return Result.err(
        const AppFailure('A IA não retornou uma identificação válida.'),
      );
    }
    final json = jsonDecode(text.substring(start, end + 1))
        as Map<String, dynamic>;

    return Result.ok(CardIdentification(
      name: (json['name'] as String?)?.trim() ?? '',
      set: (json['set'] as String?)?.trim() ?? '',
      collectorNumber:
          (json['collector_number']?.toString() ?? '').trim(),
      confidence:
          ((json['confidence'] as num?)?.toDouble() ?? 0).clamp(0, 1),
      notes: (json['notes'] as String?) ?? '',
      source: IdentificationSource.ai,
    ));
  } catch (e) {
    return Result.err(AppFailure(
      'Não foi possível interpretar a resposta da IA.',
      cause: e,
    ));
  }
}

/// Falha padronizada para erros HTTP dos provedores.
AppFailure aiHttpFailure(Object cause, {int? statusCode}) {
  if (statusCode == 401 || statusCode == 403) {
    return AppFailure(
      'Chave de IA inválida ou sem permissão. Confira nas Configurações.',
      cause: cause,
    );
  }
  if (statusCode == 429) {
    return AppFailure(
      'Limite de uso da IA atingido. Aguarde um pouco e tente de novo.',
      cause: cause,
    );
  }
  return AppFailure(
    'O provedor de IA respondeu com erro. Tente novamente.',
    cause: cause,
  );
}
