import 'package:arcane_scanner/data/collection_importer.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseWebJson', () {
    test('lista completa exportada do app web', () {
      final result = parseWebJson('''
      [
        {
          "scryfallId": "abc-123",
          "name": "Sol Ring",
          "setCode": "c21",
          "setName": "Commander 2021",
          "collectorNumber": "263",
          "rarity": "uncommon",
          "quantity": 2,
          "foil": true,
          "condition": "LP",
          "language": "PT",
          "priceUsdAtAdd": "1.50",
          "addedAt": "2025-06-01T12:00:00Z"
        }
      ]
      ''');
      final entries =
          result.when(ok: (v) => v, err: (f) => fail(f.message));
      expect(entries, hasLength(1));
      final e = entries.single;
      expect(e.scryfallId, 'abc-123');
      expect(e.quantity, 2);
      expect(e.foil, isTrue);
      expect(e.condition, Condition.lp);
      expect(e.language, Language.pt);
      expect(e.addedAt.year, 2025);
    });

    test('aceita objeto com chave "entries" e defaults para opcionais', () {
      final result = parseWebJson('''
      {"entries": [
        {"scryfallId": "x", "name": "Opt", "setCode": "xln",
         "setName": "Ixalan", "collectorNumber": "65"}
      ]}
      ''');
      final e = result
          .when(ok: (v) => v, err: (f) => fail(f.message))
          .single;
      expect(e.quantity, 1);
      expect(e.foil, isFalse);
      expect(e.condition, Condition.nm);
      expect(e.language, Language.en);
    });

    test('descarta entradas sem scryfallId e falha se nada sobrar', () {
      final result = parseWebJson('[{"name": "Sem Id"}]');
      expect(result.isOk, isFalse);
    });

    test('JSON malformado vira falha amigável', () {
      expect(parseWebJson('não é json').isOk, isFalse);
    });
  });

  group('parseExportCsv', () {
    const header =
        'Count,Name,Edition,Collector Number,Foil,Condition,Language,'
        'Rarity,Price USD (at add),Price EUR (at add),Added At';

    test('linha padrão do nosso export', () {
      final result = parseExportCsv(
        '$header\r\n'
        '4,Lightning Bolt,NEO,123,foil,LP,PT,rare,1.23,1.10,'
        '2026-07-07T12:00:00.000Z\r\n',
      );
      final row =
          result.when(ok: (v) => v, err: (f) => fail(f.message)).single;
      expect(row.count, 4);
      expect(row.edition, 'NEO');
      expect(row.foil, isTrue);
      expect(row.condition, Condition.lp);
      expect(row.language, Language.pt);
      expect(row.addedAt?.day, 7);
    });

    test('nome com vírgula entre aspas', () {
      final result = parseExportCsv(
        '$header\r\n'
        '1,"Ach! Hans, Run!",UNH,15,,NM,EN,rare,,,\r\n',
      );
      final row =
          result.when(ok: (v) => v, err: (f) => fail(f.message)).single;
      expect(row.name, 'Ach! Hans, Run!');
      expect(row.foil, isFalse);
    });

    test('cabeçalhos desconhecidos viram falha clara', () {
      final result = parseExportCsv('Foo,Bar\r\n1,2\r\n');
      expect(result.isOk, isFalse);
    });
  });
}
