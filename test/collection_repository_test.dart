import 'package:arcane_scanner/data/collection_repository.dart';
import 'package:arcane_scanner/data/db/app_database.dart';
import 'package:arcane_scanner/domain/models/collection_entry.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

CollectionEntry _entry({
  String scryfallId = 'bolt-1',
  String name = 'Lightning Bolt',
  String setCode = 'neo',
  String? rarity = 'rare',
  int quantity = 1,
  bool foil = false,
  Condition condition = Condition.nm,
  Language language = Language.en,
}) =>
    CollectionEntry(
      scryfallId: scryfallId,
      name: name,
      setCode: setCode,
      setName: 'Set $setCode',
      collectorNumber: '1',
      rarity: rarity,
      quantity: quantity,
      foil: foil,
      condition: condition,
      language: language,
      addedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  late AppDatabase db;
  late CollectionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CollectionRepository(db);
  });

  tearDown(() => db.close());

  Future<List<CollectionEntry>> all([CollectionFilter? f]) =>
      repo.watch(f ?? const CollectionFilter()).first;

  group('regra de merge', () {
    test('mesma impressão + mesmo estado incrementa quantity', () async {
      await repo.add(_entry(quantity: 1));
      await repo.add(_entry(quantity: 3));

      final entries = await all();
      expect(entries, hasLength(1));
      expect(entries.single.quantity, 4);
    });

    test('foil diferente cria linha separada', () async {
      await repo.add(_entry());
      await repo.add(_entry(foil: true));
      expect(await all(), hasLength(2));
    });

    test('condição ou idioma diferente cria linha separada', () async {
      await repo.add(_entry());
      await repo.add(_entry(condition: Condition.lp));
      await repo.add(_entry(language: Language.pt));
      expect(await all(), hasLength(3));
    });
  });

  group('filtros', () {
    setUp(() async {
      await repo.add(_entry(
          scryfallId: 'a', name: 'Lightning Bolt', setCode: 'neo'));
      await repo.add(_entry(
          scryfallId: 'b',
          name: 'Counterspell',
          setCode: 'mh2',
          rarity: 'uncommon'));
      await repo.add(
          _entry(scryfallId: 'c', name: 'Bolt of Light', setCode: 'mh2'));
    });

    test('busca por nome é parcial e case-insensitive', () async {
      final entries =
          await all(const CollectionFilter(nameQuery: 'bolt'));
      expect(entries.map((e) => e.name),
          containsAll(['Lightning Bolt', 'Bolt of Light']));
      expect(entries, hasLength(2));
    });

    test('filtra por edição', () async {
      final entries = await all(const CollectionFilter(setCode: 'mh2'));
      expect(entries, hasLength(2));
    });

    test('filtra por raridade combinada com edição', () async {
      final entries = await all(
          const CollectionFilter(setCode: 'mh2', rarity: 'uncommon'));
      expect(entries.single.name, 'Counterspell');
    });
  });

  test('setQuantity e remove', () async {
    await repo.add(_entry());
    var entries = await all();
    await repo.setQuantity(entries.single.id!, 7);

    entries = await all();
    expect(entries.single.quantity, 7);

    await repo.remove(entries.single.id!);
    expect(await all(), isEmpty);
  });

  test('clearAll esvazia a coleção', () async {
    await repo.add(_entry(scryfallId: 'a'));
    await repo.add(_entry(scryfallId: 'b'));
    await repo.clearAll();
    expect(await all(), isEmpty);
  });

  test('watchSets retorna edições distintas ordenadas', () async {
    await repo.add(_entry(scryfallId: 'a', setCode: 'neo'));
    await repo.add(_entry(scryfallId: 'b', setCode: 'mh2'));
    await repo.add(_entry(scryfallId: 'c', setCode: 'mh2', foil: true));

    final sets = await repo.watchSets().first;
    expect(sets.map((s) => s.code), ['mh2', 'neo']);
  });

  test('totais somam preço x quantidade', () {
    final totals = CollectionTotals.fromEntries([
      _entry(quantity: 2).copyWith(),
      _entry(scryfallId: 'x', quantity: 3),
    ]);
    expect(totals.uniquePrintings, 2);
    expect(totals.totalQuantity, 5);
    expect(totals.totalUsd, 0); // sem preço registrado
  });
}
