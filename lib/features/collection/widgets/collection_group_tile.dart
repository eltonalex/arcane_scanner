import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../collection_grouping.dart';
import 'collection_entry_tile.dart';

/// Renderiza um grupo consolidado da coleção.
///
/// - Grupo de 1 entrada: mostra o tile normal (edição completa).
/// - Grupo de várias: cabeçalho consolidado (imagem, nome, total, resumo
///   das variantes) que EXPANDE para os tiles individuais editáveis.
class CollectionGroupTile extends StatelessWidget {
  const CollectionGroupTile({
    super.key,
    required this.group,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CollectionGroup group;
  final void Function(int entryId, int quantity) onQuantityChanged;
  final void Function(int entryId) onRemove;

  @override
  Widget build(BuildContext context) {
    // Grupo unitário: comporta-se como a lista plana de sempre.
    if (group.isSingle) {
      final e = group.representative;
      return CollectionEntryTile(
        entry: e,
        onQuantityChanged: (q) => onQuantityChanged(e.id!, q),
        onRemove: () => onRemove(e.id!),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;
    final rep = group.representative;
    final img = rep.imageUrl;

    // Subtítulo: por carta pode abranger várias edições.
    final subtitle = group.distinctSets > 1
        ? l10n.groupMultipleSets(group.distinctSets)
        : '${rep.setName} · #${rep.collectorNumber}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Theme(
        // Remove as linhas divisórias padrão do ExpansionTile.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 40,
              height: 56,
              child: img != null
                  ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
                  : ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.style_outlined),
                    ),
            ),
          ),
          title: Text(rep.name,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                group.variantSummary(),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Total consolidado (soma das variantes).
              Text('×${group.totalQuantity}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              if (group.totalUsd > 0)
                Text('\$${group.totalUsd.toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(color: gold)),
            ],
          ),
          // Ao expandir: as variantes individuais, cada uma editável.
          children: [
            for (final entry in group.entries)
              CollectionEntryTile(
                key: ValueKey(entry.id),
                entry: entry,
                onQuantityChanged: (q) => onQuantityChanged(entry.id!, q),
                onRemove: () => onRemove(entry.id!),
              ),
          ],
        ),
      ),
    );
  }
}
