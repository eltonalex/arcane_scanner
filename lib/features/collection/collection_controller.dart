import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/collection_repository.dart';
import '../../data/csv_exporter.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/collection_entry.dart';
import 'collection_grouping.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(ref.watch(appDatabaseProvider)),
);

final csvExporterProvider =
    Provider<CsvExporter>((ref) => const CsvExporter());

/// Estado dos filtros da tela (busca, edição, raridade).
class CollectionFilterNotifier extends Notifier<CollectionFilter> {
  @override
  CollectionFilter build() => const CollectionFilter();

  void setNameQuery(String value) =>
      state = state.copyWith(nameQuery: value);

  void setSetCode(String? value) =>
      state = state.copyWith(setCode: () => value);

  void setRarity(String? value) =>
      state = state.copyWith(rarity: () => value);
}

final collectionFilterProvider =
    NotifierProvider<CollectionFilterNotifier, CollectionFilter>(
        CollectionFilterNotifier.new);

/// Entradas filtradas, reativas ao banco e aos filtros.
final collectionEntriesProvider =
    StreamProvider<List<CollectionEntry>>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  final filter = ref.watch(collectionFilterProvider);
  return repo.watch(filter);
});

/// Totais SEM filtros (o cabeçalho mostra a coleção inteira).
final collectionTotalsProvider = StreamProvider<CollectionTotals>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo
      .watch(const CollectionFilter())
      .map(CollectionTotals.fromEntries);
});

/// Edições distintas para o dropdown de filtro.
final collectionSetsProvider =
    StreamProvider<List<({String code, String name})>>((ref) {
  return ref.watch(collectionRepositoryProvider).watchSets();
});

const rarityOptions = ['common', 'uncommon', 'rare', 'mythic'];

/// Modo de agrupamento da coleção, persistido em SharedPreferences.
class GroupModeNotifier extends AsyncNotifier<GroupMode> {
  static const _prefKey = 'collection_group_mode';

  @override
  Future<GroupMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefKey);
    return GroupMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => GroupMode.none,
    );
  }

  Future<void> set(GroupMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }
}

final groupModeProvider =
    AsyncNotifierProvider<GroupModeNotifier, GroupMode>(GroupModeNotifier.new);

/// Coleção já filtrada E agrupada conforme o modo escolhido.
final groupedCollectionProvider = Provider<AsyncValue<List<CollectionGroup>>>(
  (ref) {
    final entriesAsync = ref.watch(collectionEntriesProvider);
    final mode = ref.watch(groupModeProvider).valueOrNull ?? GroupMode.none;
    return entriesAsync.whenData((entries) => groupEntries(entries, mode));
  },
);
