import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/models/collection_entry.dart';
import '../../domain/models/condition.dart';
import '../../domain/models/language.dart';

part 'app_database.g.dart';

/// Tabela da coleção. O índice único em (scryfallId, foil, condition,
/// language) é o que permite a regra de merge via UPSERT: adicionar a
/// mesma impressão com o mesmo estado incrementa a quantidade em vez
/// de criar outra linha.
@DataClassName('CollectionEntryRow')
class CollectionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scryfallId => text()();
  TextColumn get name => text()();
  TextColumn get setCode => text()();
  TextColumn get setName => text()();
  TextColumn get collectorNumber => text()();
  TextColumn get rarity => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get scryfallUri => text().nullable()();
  IntColumn get quantity => integer()();
  BoolColumn get foil => boolean()();
  TextColumn get condition => textEnum<Condition>()();
  TextColumn get language => textEnum<Language>()();
  TextColumn get priceUsdAtAdd => text().nullable()();
  TextColumn get priceEurAtAdd => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {scryfallId, foil, condition, language},
      ];
}

@DriftDatabase(tables: [CollectionEntries])
class AppDatabase extends _$AppDatabase {
  /// Produção: banco em arquivo. Testes: passe NativeDatabase.memory().
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'arcane_scanner'));

  @override
  int get schemaVersion => 1;
}

/// Mapeamento Row (drift) -> modelo de domínio.
extension CollectionEntryRowMapper on CollectionEntryRow {
  CollectionEntry toDomain() => CollectionEntry(
        id: id,
        scryfallId: scryfallId,
        name: name,
        setCode: setCode,
        setName: setName,
        collectorNumber: collectorNumber,
        rarity: rarity,
        imageUrl: imageUrl,
        scryfallUri: scryfallUri,
        quantity: quantity,
        foil: foil,
        condition: condition,
        language: language,
        priceUsdAtAdd: priceUsdAtAdd,
        priceEurAtAdd: priceEurAtAdd,
        addedAt: addedAt,
      );
}

/// Mapeamento modelo de domínio -> Companion (insert).
extension CollectionEntryCompanionMapper on CollectionEntry {
  CollectionEntriesCompanion toCompanion() => CollectionEntriesCompanion.insert(
        scryfallId: scryfallId,
        name: name,
        setCode: setCode,
        setName: setName,
        collectorNumber: collectorNumber,
        rarity: Value(rarity),
        imageUrl: Value(imageUrl),
        scryfallUri: Value(scryfallUri),
        quantity: quantity,
        foil: foil,
        condition: condition,
        language: language,
        priceUsdAtAdd: Value(priceUsdAtAdd),
        priceEurAtAdd: Value(priceEurAtAdd),
        addedAt: addedAt,
      );
}
