import '../../domain/models/card_identification.dart';
import '../../domain/models/language.dart';

/// Heurísticas para extrair pistas do texto reconhecido pelo ML Kit.
///
/// Layout moderno (pós-2014) do rodapé de uma carta de Magic:
///   123/302 R
///   NEO • EN        (ou "NEO - EN", "NEO EN")
/// E o nome fica na primeira linha do topo.
///
/// Função pura: recebe as linhas já ordenadas de cima para baixo
/// (o leitor ML Kit ordena os blocos pelo boundingBox) e devolve
/// as pistas com um score de confiança.
CardIdentification parseOcrLines(List<String> rawLines) {
  final lines = rawLines
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);

  if (lines.isEmpty) {
    return const CardIdentification(source: IdentificationSource.ocr);
  }

  // --- Collector number: "123/302" (o número da carta é o primeiro) ---
  String collectorNumber = '';
  final slashPattern = RegExp(r'\b0*(\d{1,4})\s*/\s*\d{1,4}\b');
  for (final line in lines) {
    final m = slashPattern.firstMatch(line);
    if (m != null) {
      collectorNumber = m.group(1)!;
      break;
    }
  }

  // --- Set code + idioma: "NEO • EN" / "MH2 - PT" / "DSK EN" ---
  String setCode = '';
  Language? language;
  final setLangPattern = RegExp(
    r'\b([A-Z0-9]{3,5})\b\s*[•·∙\-–—*]?\s*\b'
    r'(EN|PT|ES|FR|DE|IT|JA|JP|KO|RU|ZHS|ZHT)\b',
  );
  const knownNonSets = {'THE', 'AND', 'FOR', 'YOU', 'NOT', 'ALL', 'ART'};
  for (final line in lines) {
    final m = setLangPattern.firstMatch(line.toUpperCase());
    if (m != null && !knownNonSets.contains(m.group(1))) {
      setCode = m.group(1)!;
      final langToken = m.group(2)! == 'JA' ? 'JP' : m.group(2)!;
      language = Language.fromCode(langToken);
      break;
    }
  }

  // --- Nome: primeira linha "de cara de nome" no topo ---
  // Ignora linhas que são custo de mana, números ou muito curtas.
  String name = '';
  final looksLikeName = RegExp(r'^[A-Za-zÀ-ÿ]');
  for (final line in lines.take(4)) {
    final letters = line.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    if (line.length >= 3 &&
        letters.length >= line.length * 0.6 &&
        looksLikeName.hasMatch(line)) {
      name = line;
      break;
    }
  }

  // --- Confiança ---
  double confidence;
  if (setCode.isNotEmpty && collectorNumber.isNotEmpty) {
    confidence = 0.9;
  } else if (name.isNotEmpty && collectorNumber.isNotEmpty) {
    confidence = 0.6;
  } else if (name.isNotEmpty) {
    confidence = 0.5;
  } else {
    confidence = 0.0;
  }

  return CardIdentification(
    name: name,
    set: setCode,
    collectorNumber: collectorNumber,
    confidence: confidence,
    language: language,
    notes: 'OCR local (ML Kit)',
    source: IdentificationSource.ocr,
  );
}

/// Combina a leitura da carta inteira com a leitura da faixa do rodapé.
///
/// A faixa do rodapé é recortada em alta resolução, então o set code e o
/// collector number lidos nela têm prioridade. O nome vem da carta
/// inteira (o rodapé não tem nome). O idioma prefere o do rodapé.
CardIdentification mergeOcrClues({
  required CardIdentification card,
  required CardIdentification footer,
}) {
  final set = footer.set.isNotEmpty ? footer.set : card.set;
  final collectorNumber = footer.collectorNumber.isNotEmpty
      ? footer.collectorNumber
      : card.collectorNumber;
  final name = card.hasName ? card.name : footer.name;
  final language = footer.language ?? card.language;

  double confidence;
  if (set.isNotEmpty && collectorNumber.isNotEmpty) {
    confidence = 0.92; // rodapé nítido = melhor caso
  } else if (name.isNotEmpty && collectorNumber.isNotEmpty) {
    confidence = 0.6;
  } else if (name.isNotEmpty) {
    confidence = 0.5;
  } else {
    confidence = 0.0;
  }

  return CardIdentification(
    name: name,
    set: set,
    collectorNumber: collectorNumber,
    confidence: confidence,
    language: language,
    notes: 'OCR local (carta + rodapé)',
    source: IdentificationSource.ocr,
  );
}
