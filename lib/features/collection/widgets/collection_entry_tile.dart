import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/collection_entry.dart';
import '../../../l10n/app_localizations.dart';

class CollectionEntryTile extends StatelessWidget {
  const CollectionEntryTile({
    super.key,
    required this.entry,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CollectionEntry entry;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail (Scryfall "small": 146x204)
            Semantics(
              image: true,
              label: entry.name,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 48,
                  height: 67,
                  child: entry.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: entry.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        )
                      : ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.style_outlined),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: entry.scryfallUri == null
                        ? null
                        : () => launchUrl(
                              Uri.parse(entry.scryfallUri!),
                              mode: LaunchMode.externalApplication,
                            ),
                    child: Text(
                      entry.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: entry.scryfallUri != null
                            ? TextDecoration.underline
                            : null,
                        decorationColor: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.setName} · #${entry.collectorNumber}'
                    '${entry.rarity != null ? ' · ${entry.rarity}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (entry.foil)
                        Icon(Icons.auto_awesome, size: 14, color: gold),
                      _Badge(entry.condition.code),
                      _Badge(entry.language.code),
                      if (entry.priceUsdAtAdd != null)
                        Text('\$${entry.priceUsdAtAdd}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: gold)),
                      if (entry.priceEurAtAdd != null)
                        Text('€${entry.priceEurAtAdd}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: gold)),
                    ],
                  ),
                ],
              ),
            ),
            // Quantidade + remover
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      padding: EdgeInsets.zero,
                      tooltip: l10n.decreaseQuantity,
                      onPressed: entry.quantity > 1
                          ? () => onQuantityChanged(entry.quantity - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${entry.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      padding: EdgeInsets.zero,
                      tooltip: l10n.increaseQuantity,
                      onPressed: () => onQuantityChanged(entry.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                    ),
                  ],
                ),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  padding: EdgeInsets.zero,
                  tooltip: l10n.removeEntry,
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: theme.colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}
