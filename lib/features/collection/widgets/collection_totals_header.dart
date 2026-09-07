import 'package:flutter/material.dart';

import '../../../data/collection_repository.dart';
import '../../../l10n/app_localizations.dart';

class CollectionTotalsHeader extends StatelessWidget {
  const CollectionTotalsHeader({super.key, required this.totals});

  final CollectionTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget stat(String label, String value, {bool gold = false}) => Expanded(
          child: Semantics(
            label: '$label: $value',
            excludeSemantics: true,
            child: Column(
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: gold
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            stat(l10n.totalsUnique, '${totals.uniquePrintings}'),
            stat(l10n.totalsQuantity, '${totals.totalQuantity}'),
            stat('USD', '\$${totals.totalUsd.toStringAsFixed(2)}', gold: true),
            stat('EUR', '€${totals.totalEur.toStringAsFixed(2)}', gold: true),
          ],
        ),
      ),
    );
  }
}
