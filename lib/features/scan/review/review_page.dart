import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../scan_queue.dart';
import 'widgets/queued_scan_tile.dart';

/// Tela de revisão da fila de captura: lista os itens capturados, permite
/// editar (quantidade/foil/condição/idioma) e remover, e então confirma
/// tudo de uma vez na coleção.
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  Future<void> _confirmAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final count = await ref.read(scanQueueProvider.notifier).commitAll();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.reviewAdded(count))),
    );
    navigator.pop();
  }

  Future<void> _discardAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reviewDiscardTitle),
        content: Text(l10n.reviewDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reviewDiscard),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(scanQueueProvider.notifier).clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final queue = ref.watch(scanQueueProvider);
    final notifier = ref.read(scanQueueProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewTitle(queue.length)),
        actions: [
          if (queue.isNotEmpty)
            IconButton(
              tooltip: l10n.reviewDiscard,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _discardAll(context, ref),
            ),
        ],
      ),
      body: queue.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.reviewEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96, top: 8),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final item = queue[index];
                return QueuedScanTile(
                  key: ValueKey(item.id),
                  item: item,
                  onChanged: ({quantity, foil, condition, language}) =>
                      notifier.updateItem(
                    item.id,
                    quantity: quantity,
                    foil: foil,
                    condition: condition,
                    language: language,
                  ),
                  onRemove: () => notifier.remove(item.id),
                );
              },
            ),
      bottomSheet: queue.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => _confirmAll(context, ref),
                  icon: const Icon(Icons.library_add_check),
                  label: Text(l10n.reviewConfirmAll(queue.length)),
                ),
              ),
            ),
    );
  }
}
