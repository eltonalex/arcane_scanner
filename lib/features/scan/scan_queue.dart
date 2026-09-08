import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/card_identification_service.dart';
import '../../domain/models/condition.dart';
import '../../domain/models/language.dart';
import '../collection/collection_controller.dart';

/// Um item da fila de captura: a carta identificada + os atributos
/// escolhidos (editáveis na revisão). Só vira entrada da coleção quando
/// o usuário confirma a lista.
class QueuedScan {
  const QueuedScan({
    required this.id,
    required this.result,
    this.quantity = 1,
    this.foil = false,
    this.condition = Condition.nm,
    required this.language,
  });

  final String id;
  final IdentifiedCard result;
  final int quantity;
  final bool foil;
  final Condition condition;
  final Language language;

  QueuedScan copyWith({
    int? quantity,
    bool? foil,
    Condition? condition,
    Language? language,
  }) =>
      QueuedScan(
        id: id,
        result: result,
        quantity: quantity ?? this.quantity,
        foil: foil ?? this.foil,
        condition: condition ?? this.condition,
        language: language ?? this.language,
      );
}

/// Fila em memória de uma sessão de captura. Não persiste entre
/// reinícios do app (são scans ainda não confirmados).
class ScanQueueNotifier extends Notifier<List<QueuedScan>> {
  var _seq = 0;

  @override
  List<QueuedScan> build() => const [];

  void add(IdentifiedCard result) {
    final id = '${DateTime.now().microsecondsSinceEpoch}_${_seq++}';
    state = [
      ...state,
      QueuedScan(
        id: id,
        result: result,
        // Idioma detectado no rodapé pré-preenche o item.
        language: result.identification.language ?? Language.en,
      ),
    ];
  }

  void updateItem(
    String id, {
    int? quantity,
    bool? foil,
    Condition? condition,
    Language? language,
  }) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            quantity: quantity,
            foil: foil,
            condition: condition,
            language: language,
          )
        else
          item,
    ];
  }

  void remove(String id) =>
      state = [for (final i in state) if (i.id != id) i];

  void clear() => state = const [];

  /// Confirma a lista: grava todos na coleção (regra de merge se aplica)
  /// e esvazia a fila. Retorna quantas cartas (linhas) foram gravadas.
  Future<int> commitAll() async {
    final repo = ref.read(collectionRepositoryProvider);
    final items = state;
    for (final item in items) {
      await repo.add(buildCollectionEntry(
        item.result,
        quantity: item.quantity,
        foil: item.foil,
        condition: item.condition,
        language: item.language,
      ));
    }
    clear();
    return items.length;
  }
}

final scanQueueProvider =
    NotifierProvider<ScanQueueNotifier, List<QueuedScan>>(
        ScanQueueNotifier.new);
