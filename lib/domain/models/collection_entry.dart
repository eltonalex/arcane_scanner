import 'condition.dart';
import 'language.dart';

/// Entrada da coleção — modelo de domínio puro.
///
/// Na iteração 2, a tabela drift terá os mesmos campos e o repositório
/// fará o mapeamento Row <-> CollectionEntry. Manter este modelo
/// independente do banco deixa o exportador de CSV e a UI testáveis
/// sem tocar em SQLite.
class CollectionEntry {
  const CollectionEntry({
    this.id,
    required this.scryfallId,
    required this.name,
    required this.setCode,
    required this.setName,
    required this.collectorNumber,
    this.rarity,
    this.imageUrl,
    this.scryfallUri,
    required this.quantity,
    required this.foil,
    required this.condition,
    required this.language,
    this.priceUsdAtAdd,
    this.priceEurAtAdd,
    required this.addedAt,
  });

  final int? id; // null até ser persistido
  final String scryfallId;
  final String name;
  final String setCode; // ex: "neo"
  final String setName; // ex: "Kamigawa: Neon Dynasty"
  final String collectorNumber;
  final String? rarity; // common | uncommon | rare | mythic
  final String? imageUrl;
  final String? scryfallUri;
  final int quantity;
  final bool foil;
  final Condition condition;
  final Language language;
  final String? priceUsdAtAdd;
  final String? priceEurAtAdd;
  final DateTime addedAt;

  /// Chave da regra de merge: mesma impressão + foil + condição + idioma.
  (String, bool, Condition, Language) get mergeKey =>
      (scryfallId, foil, condition, language);

  CollectionEntry copyWith({int? id, int? quantity}) => CollectionEntry(
        id: id ?? this.id,
        scryfallId: scryfallId,
        name: name,
        setCode: setCode,
        setName: setName,
        collectorNumber: collectorNumber,
        rarity: rarity,
        imageUrl: imageUrl,
        scryfallUri: scryfallUri,
        quantity: quantity ?? this.quantity,
        foil: foil,
        condition: condition,
        language: language,
        priceUsdAtAdd: priceUsdAtAdd,
        priceEurAtAdd: priceEurAtAdd,
        addedAt: addedAt,
      );
}
