import 'package:arcane_scanner/data/csv_exporter.dart';
import 'package:arcane_scanner/domain/models/collection_entry.dart';
import 'package:arcane_scanner/domain/models/condition.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:flutter_test/flutter_test.dart';

CollectionEntry _entry({
  String name = 'Lightning Bolt',
  String setCode = 'neo',
  bool foil = false,
  String? priceUsd = '1.23',
}) =>
    CollectionEntry(
      scryfallId: 'abc-123',
      name: name,
      setCode: setCode,
      setName: 'Kamigawa: Neon Dynasty',
      collectorNumber: '123',
      rarity: 'rare',
      quantity: 4,
      foil: foil,
      condition: Condition.nm,
      language: Language.pt,
      priceUsdAtAdd: priceUsd,
      priceEurAtAdd: '1.10',
      addedAt: DateTime.utc(2026, 7, 7, 12, 0, 0),
    );

void main() {
  const exporter = CsvExporter();

  test('gera cabeçalhos exatos compatíveis com Moxfield', () {
    final csv = exporter.buildCsv([]);
    expect(
      csv.split('\r\n').first,
      'Count,Name,Edition,Collector Number,Foil,Condition,Language,Rarity,'
      'Price USD (at add),Price EUR (at add),Added At',
    );
  });

  test('Edition em uppercase, foil vazio quando false e data em ISO 8601',
      () {
    final csv = exporter.buildCsv([_entry()]);
    final row = csv.split('\r\n')[1];
    expect(row, contains('NEO'));
    expect(row, contains(',,NM,PT,')); // Foil vazio entre nº e condição
    expect(row, contains('2026-07-07T12:00:00.000Z'));
  });

  test('foil=true vira a palavra "foil"', () {
    final csv = exporter.buildCsv([_entry(foil: true)]);
    expect(csv.split('\r\n')[1], contains(',foil,NM,'));
  });

  test('escapa vírgulas, aspas e quebras de linha no nome', () {
    final csv = exporter.buildCsv([
      _entry(name: 'Ach! Hans, Run!\nDiz "corra"'),
    ]);
    // RFC 4180: campo com vírgula/aspas/quebra vem entre aspas,
    // e aspas internas são duplicadas.
    expect(csv, contains('"Ach! Hans, Run!\nDiz ""corra"""'));
  });

  test('campos nulos viram string vazia', () {
    final csv = exporter.buildCsv([_entry(priceUsd: null)]);
    final row = csv.split('\r\n')[1];
    expect(row, contains(',rare,,1.10,'));
  });
}
