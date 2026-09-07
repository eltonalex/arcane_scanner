import 'dart:convert';

import 'package:csv/csv.dart';

import '../core/result.dart';
import '../domain/models/collection_entry.dart';
import '../domain/models/condition.dart';
import '../domain/models/language.dart';
import 'collection_repository.dart';
import 'scryfall_api.dart';

/// Relatório de uma importação.
class ImportReport {
  const ImportReport({
    required this.imported,
    required this.failed,
    this.errors = const [],
  });

  final int imported;
  final int failed;
  final List<String> errors; // primeiras mensagens, para exibir
}

/// ---------- Parsers puros (testáveis sem banco/rede) ----------

/// JSON exportado do localStorage do app web (lista de entradas com os
/// mesmos campos do modelo). Tolerante a campos ausentes/opcionais.
Result<List<CollectionEntry>> parseWebJson(String content) {
  try {
    final decoded = jsonDecode(content);
    final list = decoded is List
        ? decoded
        : (decoded is Map && decoded['entries'] is List)
            ? decoded['entries'] as List
            : null;
    if (list == null) {
      return Result.err(const AppFailure(
        'O JSON não tem o formato esperado (lista de cartas).',
      ));
    }

    final entries = <CollectionEntry>[];
    for (final item in list) {
      final m = item as Map<String, dynamic>;
      entries.add(CollectionEntry(
        scryfallId: (m['scryfallId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        setCode: (m['setCode'] ?? '') as String,
        setName: (m['setName'] ?? '') as String,
        collectorNumber: (m['collectorNumber'] ?? '').toString(),
        rarity: m['rarity'] as String?,
        imageUrl: m['imageUrl'] as String?,
        scryfallUri: m['scryfallUri'] as String?,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
        foil: m['foil'] == true,
        condition: Condition.fromCode((m['condition'] ?? 'NM').toString()),
        language: Language.fromCode((m['language'] ?? 'EN').toString()),
        priceUsdAtAdd: m['priceUsdAtAdd']?.toString(),
        priceEurAtAdd: m['priceEurAtAdd']?.toString(),
        addedAt: DateTime.tryParse((m['addedAt'] ?? '').toString()) ??
            DateTime.now().toUtc(),
      ));
    }
    final valid = entries
        .where((e) => e.scryfallId.isNotEmpty && e.name.isNotEmpty)
        .toList(growable: false);
    if (valid.isEmpty) {
      return Result.err(const AppFailure(
        'Nenhuma carta válida encontrada no JSON (scryfallId é obrigatório).',
      ));
    }
    return Result.ok(valid);
  } catch (e) {
    return Result.err(
      AppFailure('Não foi possível ler o arquivo JSON.', cause: e),
    );
  }
}

/// Linha crua do CSV exportado (formato Moxfield deste app).
class CsvRow {
  const CsvRow({
    required this.count,
    required this.name,
    required this.edition,
    required this.collectorNumber,
    required this.foil,
    required this.condition,
    required this.language,
    this.priceUsd,
    this.priceEur,
    this.addedAt,
  });

  final int count;
  final String name;
  final String edition;
  final String collectorNumber;
  final bool foil;
  final Condition condition;
  final Language language;
  final String? priceUsd;
  final String? priceEur;
  final DateTime? addedAt;
}

Result<List<CsvRow>> parseExportCsv(String content) {
  try {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(content.replaceAll('\r\n', '\n'));
    if (rows.length < 2) {
      return Result.err(const AppFailure('O CSV está vazio.'));
    }

    final headers =
        rows.first.map((h) => h.toString().trim()).toList(growable: false);
    int col(String name) => headers.indexOf(name);
    final iCount = col('Count');
    final iName = col('Name');
    final iEdition = col('Edition');
    final iNumber = col('Collector Number');
    if ([iCount, iName, iEdition, iNumber].contains(-1)) {
      return Result.err(const AppFailure(
        'Cabeçalhos do CSV não reconhecidos. Use um arquivo exportado '
        'por este app (formato Moxfield).',
      ));
    }
    final iFoil = col('Foil');
    final iCondition = col('Condition');
    final iLanguage = col('Language');
    final iUsd = col('Price USD (at add)');
    final iEur = col('Price EUR (at add)');
    final iAdded = col('Added At');

    String cell(List row, int index) =>
        (index >= 0 && index < row.length) ? row[index].toString() : '';

    final parsed = <CsvRow>[];
    for (final row in rows.skip(1)) {
      if (row.every((c) => c.toString().trim().isEmpty)) continue;
      parsed.add(CsvRow(
        count: int.tryParse(cell(row, iCount)) ?? 1,
        name: cell(row, iName),
        edition: cell(row, iEdition),
        collectorNumber: cell(row, iNumber),
        foil: cell(row, iFoil).toLowerCase() == 'foil',
        condition: Condition.fromCode(cell(row, iCondition)),
        language: Language.fromCode(cell(row, iLanguage)),
        priceUsd: cell(row, iUsd).isEmpty ? null : cell(row, iUsd),
        priceEur: cell(row, iEur).isEmpty ? null : cell(row, iEur),
        addedAt: DateTime.tryParse(cell(row, iAdded)),
      ));
    }
    return Result.ok(parsed);
  } catch (e) {
    return Result.err(
      AppFailure('Não foi possível ler o arquivo CSV.', cause: e),
    );
  }
}

/// ---------- Importador (usa repo e, para CSV, o Scryfall) ----------

class CollectionImporter {
  CollectionImporter({required this.repository, required this.scryfall});

  final CollectionRepository repository;
  final ScryfallApi scryfall;

  Future<Result<ImportReport>> importJson(String content) async {
    final parsed = parseWebJson(content);
    switch (parsed) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final entries):
        var imported = 0;
        for (final entry in entries) {
          await repository.add(entry); // regra de merge se aplica
          imported++;
        }
        return Result.ok(ImportReport(imported: imported, failed: 0));
    }
  }

  /// CSV não carrega scryfallId/imagem/nome da edição — cada linha é
  /// enriquecida no Scryfall por (Edition, Collector Number). Respeita
  /// o rate limit da API (~10 req/s) com um pequeno intervalo.
  Future<Result<ImportReport>> importCsv(
    String content, {
    void Function(int done, int total)? onProgress,
  }) async {
    final parsed = parseExportCsv(content);
    switch (parsed) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final rows):
        if (rows.isEmpty) {
          return Result.err(const AppFailure('O CSV não tem linhas.'));
        }
        var imported = 0;
        var failed = 0;
        final errors = <String>[];

        for (var i = 0; i < rows.length; i++) {
          final row = rows[i];
          final card = await scryfall.byCodeAndNumber(
            row.edition,
            row.collectorNumber,
          );
          switch (card) {
            case Err(:final failure):
              failed++;
              if (errors.length < 5) {
                errors.add('${row.name}: ${failure.message}');
              }
            case Ok(value: final c):
              await repository.add(CollectionEntry(
                scryfallId: c.id,
                name: c.name,
                setCode: c.setCode,
                setName: c.setName,
                collectorNumber: c.collectorNumber,
                rarity: c.rarity,
                imageUrl: c.imageSmall ?? c.imageNormal,
                scryfallUri: c.scryfallUri,
                quantity: row.count,
                foil: row.foil,
                condition: row.condition,
                language: row.language,
                priceUsdAtAdd: row.priceUsd ?? c.priceUsd,
                priceEurAtAdd: row.priceEur ?? c.priceEur,
                addedAt: row.addedAt ?? DateTime.now().toUtc(),
              ));
              imported++;
          }
          onProgress?.call(i + 1, rows.length);
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
        return Result.ok(ImportReport(
          imported: imported,
          failed: failed,
          errors: errors,
        ));
    }
  }
}
