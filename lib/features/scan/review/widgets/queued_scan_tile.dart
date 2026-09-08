import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/condition.dart';
import '../../../../domain/models/language.dart';
import '../../../../l10n/app_localizations.dart';
import '../../scan_queue.dart';

/// Linha editável da tela de revisão: miniatura + nome + controles de
/// quantidade/foil/condição/idioma + remover.
class QueuedScanTile extends StatelessWidget {
  const QueuedScanTile({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final QueuedScan item;
  final void Function({
    int? quantity,
    bool? foil,
    Condition? condition,
    Language? language,
  }) onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final card = item.result.card;
    final gold = theme.colorScheme.secondary;
    final img = card.imageSmall ?? card.imageNormal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 46,
                    height: 64,
                    child: img != null
                        ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.style_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${card.setName} · #${card.collectorNumber}'
                        '${card.rarity != null ? ' · ${card.rarity}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.priceUsd != null)
                        Text('\$${card.priceUsd}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: gold)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.removeEntry,
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Quantidade
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: item.quantity > 1
                      ? () => onChanged(quantity: item.quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${item.quantity}', style: theme.textTheme.titleSmall),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onChanged(quantity: item.quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                // Foil
                Text(l10n.foil, style: theme.textTheme.bodySmall),
                Switch(
                  value: item.foil,
                  onChanged: (v) => onChanged(foil: v),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Condition>(
                    initialValue: item.condition,
                    isDense: true,
                    decoration: InputDecoration(
                        labelText: l10n.conditionLabel, isDense: true),
                    items: [
                      for (final c in Condition.values)
                        DropdownMenuItem(value: c, child: Text(c.code)),
                    ],
                    onChanged: (v) =>
                        onChanged(condition: v ?? item.condition),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<Language>(
                    initialValue: item.language,
                    isDense: true,
                    decoration: InputDecoration(
                        labelText: l10n.languageLabel, isDense: true),
                    items: [
                      for (final lang in Language.values)
                        DropdownMenuItem(value: lang, child: Text(lang.code)),
                    ],
                    onChanged: (v) => onChanged(language: v ?? item.language),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
