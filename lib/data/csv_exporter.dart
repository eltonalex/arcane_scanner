import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/result.dart';
import '../domain/models/collection_entry.dart';

/// Gera e compartilha o CSV da coleção no formato aceito por
/// Moxfield/Deckbox.
///
/// A geração da string (buildCsv) é pura e coberta por testes;
/// salvar/compartilhar usa path_provider + share_plus.
class CsvExporter {
  const CsvExporter();

  static const headers = [
    'Count',
    'Name',
    'Edition',
    'Collector Number',
    'Foil',
    'Condition',
    'Language',
    'Rarity',
    'Price USD (at add)',
    'Price EUR (at add)',
    'Added At',
  ];

  /// Monta o conteúdo do CSV. O pacote `csv` cuida do escape de
  /// vírgulas, aspas e quebras de linha (RFC 4180).
  String buildCsv(List<CollectionEntry> entries) {
    final rows = <List<Object?>>[
      headers,
      for (final e in entries)
        [
          e.quantity,
          e.name,
          e.setCode.toUpperCase(), // Edition sempre em UPPERCASE
          e.collectorNumber,
          e.foil ? 'foil' : '', // convenção Moxfield
          e.condition.code,
          e.language.code,
          e.rarity ?? '',
          e.priceUsdAtAdd ?? '',
          e.priceEurAtAdd ?? '',
          e.addedAt.toUtc().toIso8601String(),
        ],
    ];
    return const ListToCsvConverter(eol: '\r\n').convert(rows);
  }

  /// Salva em arquivo temporário e abre o diálogo nativo de
  /// compartilhamento. Retorna o caminho do arquivo gerado.
  Future<Result<String>> exportAndShare(List<CollectionEntry> entries) async {
    try {
      final csvContent = buildCsv(entries);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File('${dir.path}/arcane_scanner_$stamp.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Coleção Arcane Scanner',
      );
      return Result.ok(file.path);
    } catch (e) {
      return Result.err(
        AppFailure('Não foi possível exportar a coleção.', cause: e),
      );
    }
  }
}
