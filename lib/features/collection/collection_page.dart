import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'collection_controller.dart';
import 'widgets/collection_entry_tile.dart';
import 'widgets/collection_totals_header.dart';

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  Timer? _debounce;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(collectionFilterProvider.notifier).setNameQuery(value);
    });
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final entries = ref.read(collectionEntriesProvider).valueOrNull ?? [];

    if (entries.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportEmpty)));
      return;
    }
    final result =
        await ref.read(csvExporterProvider).exportAndShare(entries);
    result.when(
      ok: (_) => messenger
          .showSnackBar(SnackBar(content: Text(l10n.exportSuccess))),
      err: (f) =>
          messenger.showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _confirmClearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllConfirmTitle),
        content: Text(l10n.clearAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(collectionRepositoryProvider).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(collectionEntriesProvider);
    final totalsAsync = ref.watch(collectionTotalsProvider);
    final setsAsync = ref.watch(collectionSetsProvider);
    final filter = ref.watch(collectionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collectionTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.ios_share),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: l10n.clearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          if (totalsAsync.valueOrNull case final totals?)
            CollectionTotalsHeader(totals: totals),
          // Filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: filter.setCode,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.filterSet,
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.filterAll)),
                      ...?setsAsync.valueOrNull?.map(
                        (s) => DropdownMenuItem(
                          value: s.code,
                          child: Text(s.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) => ref
                        .read(collectionFilterProvider.notifier)
                        .setSetCode(v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: filter.rarity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.filterRarity,
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.filterAll)),
                      ...rarityOptions.map(
                        (r) => DropdownMenuItem(value: r, child: Text(r)),
                      ),
                    ],
                    onChanged: (v) => ref
                        .read(collectionFilterProvider.notifier)
                        .setRarity(v),
                  ),
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  l10n.collectionLoadError,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.collectionEmpty,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final repo = ref.read(collectionRepositoryProvider);
                    return CollectionEntryTile(
                      key: ValueKey(entry.id),
                      entry: entry,
                      onQuantityChanged: (q) =>
                          repo.setQuantity(entry.id!, q),
                      onRemove: () => repo.remove(entry.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
