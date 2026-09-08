import 'dart:typed_data';

import '../core/result.dart';
import '../domain/models/card_identification.dart';
import '../domain/models/collection_entry.dart';
import '../domain/models/condition.dart';
import '../domain/models/language.dart';
import '../domain/models/scryfall_card.dart';
import 'ai/ai_config.dart';
import 'ocr/ocr_card_reader.dart';
import 'ocr/ocr_text_parser.dart';
import 'scryfall_api.dart';

/// Monta uma entrada de coleção a partir de uma carta identificada +
/// atributos escolhidos pelo usuário. Reutilizado pelo scan manual,
/// pela fila de revisão e por onde mais precisar (evita duplicação).
CollectionEntry buildCollectionEntry(
  IdentifiedCard identified, {
  int quantity = 1,
  bool foil = false,
  Condition condition = Condition.nm,
  Language? language,
}) {
  final card = identified.card;
  return CollectionEntry(
    scryfallId: card.id,
    name: card.name,
    setCode: card.setCode,
    setName: card.setName,
    collectorNumber: card.collectorNumber,
    rarity: card.rarity,
    imageUrl: card.imageSmall ?? card.imageNormal,
    scryfallUri: card.scryfallUri,
    quantity: quantity,
    foil: foil,
    condition: condition,
    language: language ?? identified.identification.language ?? Language.en,
    priceUsdAtAdd: card.priceUsd,
    priceEurAtAdd: card.priceEur,
    addedAt: DateTime.now().toUtc(),
  );
}


/// Resultado final: a carta do Scryfall + como ela foi identificada.
class IdentifiedCard {
  const IdentifiedCard({required this.card, required this.identification});

  final ScryfallCard card;
  final CardIdentification identification;
}

/// Pipeline híbrido:
///   1. OCR local (grátis, offline) -> resolve no Scryfall
///   2. Se falhar: IA multimodal (se configurada) -> resolve no Scryfall
///
/// Em cada etapa, a resolução tenta primeiro set+número (precisão de
/// impressão) e cai para busca fuzzy por nome.
class CardIdentificationService {
  CardIdentificationService({
    required this.ocr,
    required this.scryfall,
    required this.aiConfig,
  });

  final OcrCardReader ocr;
  final ScryfallApi scryfall;
  final AiConfigRepository aiConfig;

  Future<Result<IdentifiedCard>> identify({
    required String imagePath,
    required Uint8List compressedJpeg,
    String? footerImagePath,
  }) async {
    // ---- Etapa 1: OCR local ----
    final clues = await _readOcr(imagePath, footerImagePath);
    if (clues != null && !clues.isEmpty) {
      final card = await _resolve(clues);
      if (card case Ok(value: final c)) {
        return Result.ok(IdentifiedCard(card: c, identification: clues));
      }
    }

    // ---- Etapa 2: IA multimodal (fallback) ----
    final ai = await aiConfig.buildIdentifier();
    if (ai == null) {
      return Result.err(const AppFailure(
        'Não consegui identificar a carta pela leitura da imagem. '
        'Tente outra foto com o rodapé nítido, ou configure uma chave '
        'de IA nas Configurações para ativar o fallback inteligente.',
      ));
    }

    final aiResult = await ai.identify(compressedJpeg);
    switch (aiResult) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final clues):
        if (clues.isEmpty) {
          return Result.err(const AppFailure(
            'A IA não conseguiu reconhecer uma carta nessa imagem. '
            'Tente uma foto com melhor iluminação e enquadramento.',
          ));
        }
        final card = await _resolve(clues);
        return card.map(
          (c) => IdentifiedCard(card: c, identification: clues),
        );
    }
  }

  /// Lê a carta inteira e, se houver, a faixa do rodapé (alta resolução),
  /// combinando as pistas. O rodapé melhora set code + collector number.
  Future<CardIdentification?> _readOcr(
    String imagePath,
    String? footerImagePath,
  ) async {
    final cardResult = await ocr.read(imagePath);
    final cardClues = switch (cardResult) {
      Ok(value: final c) => c,
      Err() => null,
    };

    if (footerImagePath == null) return cardClues;

    final footerResult = await ocr.read(footerImagePath);
    final footerClues = switch (footerResult) {
      Ok(value: final c) => c,
      Err() => null,
    };

    if (cardClues == null) return footerClues;
    if (footerClues == null) return cardClues;
    return mergeOcrClues(card: cardClues, footer: footerClues);
  }

  /// set+número primeiro (identifica a IMPRESSÃO exata); fuzzy depois.
  Future<Result<ScryfallCard>> _resolve(CardIdentification clues) async {
    if (clues.hasSetAndNumber) {
      final exact =
          await scryfall.byCodeAndNumber(clues.set, clues.collectorNumber);
      if (exact.isOk) return exact;
    }
    if (clues.hasName) {
      return scryfall.byFuzzyName(clues.name);
    }
    return Result.err(const AppFailure(
      'A leitura não trouxe informações suficientes para buscar a carta.',
    ));
  }
}
