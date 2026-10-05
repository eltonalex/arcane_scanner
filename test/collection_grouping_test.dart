import 'package:arcane_scanner/domain/models/collection_entry.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:arcane_scanner/features/collection/collection_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

CollectionEntry _e({
  int? id,
  String scryfallId = 'bolt-neo',
  String name = 'Lightning Bolt',
  String setCode = 'neo',
  int quantity = 1,
  bool foil = false,
  Condition condition = Condition.nm,
  Language language = Language.en,
  String? usd = '1.00',
}) =>
    CollectionEntry(
      id: id,
      scryfallId: scryfallId,
      name: name,
      setCode: setCode,
      setName: 'Set $setCode',
      collectorNumber: '1',
      quantity: quantity,
      foil: foil,
      condition: condition,
      language: language,
      priceUsdAtAdd: usd,
      addedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('groupEntries', () {
    test('none: cada entrada vira um grupo unitário', () {
      final groups = groupEntries([
        _e(id: 1),
        _e(id: 2, foil: true),
      ], GroupMode.none);
      expect(groups, hasLength(2));
      expect(groups.every((g) => g.isSingle), isTrue);
    });

    test('printing: junta variantes da mesma impressão', () {
      final groups = groupEntries([
        _e(id: 1, quantity: 2), // NM/EN
        _e(id: 2, foil: true, quantity: 1), // Foil NM/EN
        _e(id: 3, language: Language.pt, quantity: 3), // NM/PT
      ], GroupMode.printing);

      expect(groups, hasLength(1));
      final g = groups.single;
      expect(g.isSingle, isFalse);
      expect(g.totalQuantity, 6);
      expect(g.entries, hasLength(3));
    });

    test('printing: impressões diferentes ficam em grupos diferentes', () {
      final groups = groupEntries([
        _e(id: 1, scryfallId: 'bolt-neo', setCode: 'neo'),
        _e(id: 2, scryfallId: 'bolt-mh2', setCode: 'mh2'),
      ], GroupMode.printing);
      expect(groups, hasLength(2));
    });

    test('card: junta impressões de edições diferentes pelo nome', () {
      final groups = groupEntries([
        _e(id: 1, scryfallId: 'bolt-neo', setCode: 'neo', quantity: 2),
        _e(id: 2, scryfallId: 'bolt-mh2', setCode: 'mh2', quantity: 1),
      ], GroupMode.card);

      expect(groups, hasLength(1));
      final g = groups.single;
      expect(g.totalQuantity, 3);
      expect(g.distinctSets, 2);
    });

    test('totais de preço somam preço × quantidade', () {
      final groups = groupEntries([
        _e(id: 1, quantity: 2, usd: '1.50'),
        _e(id: 2, foil: true, quantity: 1, usd: '4.00'),
      ], GroupMode.printing);
      expect(groups.single.totalUsd, closeTo(2 * 1.50 + 4.00, 0.001));
    });

    test('grupos são ordenados por nome', () {
      final groups = groupEntries([
        _e(id: 1, scryfallId: 'sol', name: 'Sol Ring'),
        _e(id: 2, scryfallId: 'ancestral', name: 'Ancestral Recall'),
      ], GroupMode.printing);
      expect(groups.first.representative.name, 'Ancestral Recall');
    });

    test('variantSummary descreve as variantes', () {
      final g = groupEntries([
        _e(id: 1, quantity: 2),
        _e(id: 2, foil: true, language: Language.pt, quantity: 1),
      ], GroupMode.printing).single;
      final summary = g.variantSummary();
      expect(summary, contains('NM·EN ×2'));
      expect(summary, contains('Foil NM·PT ×1'));
    });
  });
}
