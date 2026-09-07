/// Carta retornada pela API do Scryfall — apenas os campos que o app usa.
class ScryfallCard {
  const ScryfallCard({
    required this.id,
    required this.name,
    required this.setCode,
    required this.setName,
    required this.collectorNumber,
    this.rarity,
    this.typeLine,
    this.oracleText,
    this.manaCost,
    this.imageSmall,
    this.imageNormal,
    this.scryfallUri,
    this.priceUsd,
    this.priceEur,
  });

  final String id;
  final String name;
  final String setCode;
  final String setName;
  final String collectorNumber;
  final String? rarity;
  final String? typeLine;
  final String? oracleText;
  final String? manaCost;
  final String? imageSmall;
  final String? imageNormal;
  final String? scryfallUri;
  final String? priceUsd;
  final String? priceEur;

  factory ScryfallCard.fromJson(Map<String, dynamic> json) {
    // Cartas dupla-face não têm image_uris/oracle_text na raiz:
    // os dados ficam em card_faces[0].
    final faces = json['card_faces'] as List?;
    final face = (faces != null && faces.isNotEmpty)
        ? faces.first as Map<String, dynamic>
        : null;

    Map<String, dynamic>? images =
        (json['image_uris'] ?? face?['image_uris']) as Map<String, dynamic>?;
    final prices = json['prices'] as Map<String, dynamic>?;

    return ScryfallCard(
      id: json['id'] as String,
      name: json['name'] as String,
      setCode: json['set'] as String,
      setName: json['set_name'] as String,
      collectorNumber: json['collector_number'] as String,
      rarity: json['rarity'] as String?,
      typeLine: (json['type_line'] ?? face?['type_line']) as String?,
      oracleText: (json['oracle_text'] ?? face?['oracle_text']) as String?,
      manaCost: (json['mana_cost'] ?? face?['mana_cost']) as String?,
      imageSmall: images?['small'] as String?,
      imageNormal: images?['normal'] as String?,
      scryfallUri: json['scryfall_uri'] as String?,
      priceUsd: prices?['usd'] as String?,
      priceEur: prices?['eur'] as String?,
    );
  }
}
