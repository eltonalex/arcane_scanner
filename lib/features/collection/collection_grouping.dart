import '../../domain/models/collection_entry.dart';

/// Como as linhas da coleção são consolidadas na tela.
enum GroupMode {
  /// Cada variante em sua linha (comportamento padrão original).
  none,

  /// Uma linha por impressão (mesmo scryfallId): junta foil/condição/idioma.
  printing,

  /// Uma linha por nome de carta: junta todas as impressões/edições.
  card,
}

/// Um grupo consolidado de entradas que compartilham a mesma chave.
class CollectionGroup {
  const CollectionGroup({
    required this.key,
    required this.entries,
  });

  final String key;
  final List<CollectionEntry> entries;

  CollectionEntry get representative => entries.first;

  bool get isSingle => entries.length == 1;

  int get totalQuantity =>
      entries.fold(0, (sum, e) => sum + e.quantity);

  double get totalUsd => entries.fold(
      0, (sum, e) => sum + (double.tryParse(e.priceUsdAtAdd ?? '') ?? 0) * e.quantity);

  double get totalEur => entries.fold(
      0, (sum, e) => sum + (double.tryParse(e.priceEurAtAdd ?? '') ?? 0) * e.quantity);

  /// Quantas edições distintas o grupo abrange (para o modo "por carta").
  int get distinctSets => entries.map((e) => e.setCode).toSet().length;

  /// Resumo das variantes, ex.: "NM·EN ×2 · Foil NM·PT ×1".
  String variantSummary() {
    return entries.map((e) {
      final foil = e.foil ? 'Foil ' : '';
      return '$foil${e.condition.code}·${e.language.code} ×${e.quantity}';
    }).join(' · ');
  }
}

/// Agrupa a lista já filtrada conforme o modo. Função PURA e testável.
/// A ordem dos grupos segue o nome; dentro do grupo, mantém a ordem
/// recebida (que já vem ordenada por nome do repositório).
List<CollectionGroup> groupEntries(
  List<CollectionEntry> entries,
  GroupMode mode,
) {
  if (mode == GroupMode.none) {
    return [
      for (final e in entries)
        CollectionGroup(key: '${e.id}', entries: [e]),
    ];
  }

  final map = <String, List<CollectionEntry>>{};
  for (final e in entries) {
    final key = switch (mode) {
      GroupMode.printing => e.scryfallId,
      GroupMode.card => e.name.toLowerCase(),
      GroupMode.none => '${e.id}',
    };
    (map[key] ??= []).add(e);
  }

  final groups = [
    for (final entry in map.entries)
      CollectionGroup(key: entry.key, entries: entry.value),
  ];
  groups.sort((a, b) =>
      a.representative.name.toLowerCase().compareTo(
          b.representative.name.toLowerCase()));
  return groups;
}
