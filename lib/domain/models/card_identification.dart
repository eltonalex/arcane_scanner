import 'language.dart';

/// De onde veio a identificação.
enum IdentificationSource { ocr, ai }

/// Pistas extraídas da imagem (por OCR ou IA) antes de consultar o
/// Scryfall. Campos vazios ("") significam "não consegui ler".
class CardIdentification {
  const CardIdentification({
    this.name = '',
    this.set = '',
    this.collectorNumber = '',
    this.confidence = 0,
    this.notes = '',
    this.language,
    required this.source,
  });

  final String name;
  final String set;
  final String collectorNumber;
  final double confidence; // 0..1
  final String notes;
  final Language? language; // detectado no rodapé (pré-preenche o form)
  final IdentificationSource source;

  bool get hasSetAndNumber => set.isNotEmpty && collectorNumber.isNotEmpty;
  bool get hasName => name.trim().isNotEmpty;
  bool get isEmpty => !hasName && !hasSetAndNumber;
}
