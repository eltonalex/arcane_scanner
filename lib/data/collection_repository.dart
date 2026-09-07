import 'package:drift/drift.dart';

import '../domain/models/collection_entry.dart';
import 'db/app_database.dart';

/// Filtros da tela de coleção.
class CollectionFilter {
  const CollectionFilter({this.nameQuery = '', this.setCode, this.rarity});

  final String nameQuery;
  final String? setCode; // null = todas as edições
  final String? rarity; // null = todas as raridades

  CollectionFilter copyWith({
    String? nameQuery,
    String? Function()? setCode,
    String? Function()? rarity,
  }) =>
      CollectionFilter(
        nameQuery: nameQuery ?? this.nameQuery,
        setCode: setCode != null ? setCode() : this.setCode,
        rarity: rarity != null ? rarity() : this.rarity,
      );
}

/// Totais exibidos no cabeçalho da coleção.
class CollectionTotals {
  const CollectionTotals({
    required this.uniquePrintings,
    required this.totalQuantity,
    required this.totalUsd,
    required this.totalEur,
  });

  final int uniquePrintings;
  final int totalQuantity;
  final double totalUsd;
  final double totalEur;

  static CollectionTotals fromEntries(List<CollectionEntry> entries) {
    var qty = 0;
    var usd = 0.0;
    var eur = 0.0;
    for (final e in entries) {
      qty += e.quantity;
      usd += (double.tryParse(e.priceUsdAtAdd ?? '') ?? 0) * e.quantity;
      eur += (double.tryParse(e.priceEurAtAdd ?? '') ?? 0) * e.quantity;
    }
    return CollectionTotals(
      uniquePrintings: entries.length,
      totalQuantity: qty,
      totalUsd: usd,
      totalEur: eur,
    );
  }
}

class CollectionRepository {
  CollectionRepository(this._db);

  final AppDatabase _db;

  $CollectionEntriesTable get _t => _db.collectionEntries;

  /// Adiciona uma entrada. Se já existir a mesma impressão com o mesmo
  /// (foil, condition, language), soma a quantidade (regra de merge).
  Future<void> add(CollectionEntry entry) {
    return _db.into(_t).insert(
          entry.toCompanion(),
          onConflict: DoUpdate(
            (old) => CollectionEntriesCompanion.custom(
              quantity: old.quantity + Constant(entry.quantity),
            ),
            target: [_t.scryfallId, _t.foil, _t.condition, _t.language],
          ),
        );
  }

  /// Stream reativa e filtrada — a UI se atualiza sozinha a cada
  /// escrita no banco (drift.watch).
  Stream<List<CollectionEntry>> watch(CollectionFilter filter) {
    final query = _db.select(_t);

    if (filter.nameQuery.trim().isNotEmpty) {
      final q = filter.nameQuery.trim().toLowerCase();
      query.where((t) => t.name.lower().like('%$q%'));
    }
    if (filter.setCode != null) {
      query.where((t) => t.setCode.equals(filter.setCode!));
    }
    if (filter.rarity != null) {
      query.where((t) => t.rarity.equals(filter.rarity!));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    return query.watch().map(
          (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
        );
  }

  /// Edições distintas presentes na coleção (para o dropdown de filtro).
  Stream<List<({String code, String name})>> watchSets() {
    final query = _db.selectOnly(_t, distinct: true)
      ..addColumns([_t.setCode, _t.setName])
      ..orderBy([OrderingTerm.asc(_t.setName)]);
    return query.watch().map(
          (rows) => rows
              .map((r) =>
                  (code: r.read(_t.setCode)!, name: r.read(_t.setName)!))
              .toList(growable: false),
        );
  }

  Future<void> setQuantity(int id, int quantity) {
    assert(quantity >= 1, 'Use remove() para tirar a entrada da coleção');
    return (_db.update(_t)..where((t) => t.id.equals(id)))
        .write(CollectionEntriesCompanion(quantity: Value(quantity)));
  }

  Future<void> remove(int id) =>
      (_db.delete(_t)..where((t) => t.id.equals(id))).go();

  Future<void> clearAll() => _db.delete(_t).go();
}
