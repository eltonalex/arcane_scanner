import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/card_identification_service.dart';
import '../../../domain/models/card_identification.dart';
import '../../../domain/models/condition.dart';
import '../../../domain/models/language.dart';
import '../../../l10n/app_localizations.dart';
import '../scan_controller.dart';

/// Painel exibido após identificação bem-sucedida: dados da carta +
/// formulário de adição (oculto quando o modo rápido já adicionou).
class CardResultPanel extends ConsumerStatefulWidget {
  const CardResultPanel({
    super.key,
    required this.result,
    required this.autoAdded,
  });

  final IdentifiedCard result;
  final bool autoAdded;

  @override
  ConsumerState<CardResultPanel> createState() => _CardResultPanelState();
}

class _CardResultPanelState extends ConsumerState<CardResultPanel> {
  int _quantity = 1;
  bool _foil = false;
  Condition _condition = Condition.nm;
  late Language _language;

  @override
  void initState() {
    super.initState();
    // Idioma detectado no rodapé pré-preenche o formulário.
    _language = widget.result.identification.language ?? Language.en;
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(scanControllerProvider.notifier).addToCollection(
          widget.result,
          quantity: _quantity,
          foil: _foil,
          condition: _condition,
          language: _language,
        );
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.addedToCollection(widget.result.card.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final card = widget.result.card;
    final ident = widget.result.identification;
    final gold = theme.colorScheme.secondary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.imageNormal != null || card.imageSmall != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: card.imageNormal ?? card.imageSmall!,
                      width: 110,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 110,
                        height: 154,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${card.setName} · #${card.collectorNumber}'
                        '${card.rarity != null ? ' · ${card.rarity}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (card.manaCost != null &&
                          card.manaCost!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(card.manaCost!,
                            style: theme.textTheme.bodySmall),
                      ],
                      if (card.typeLine != null) ...[
                        const SizedBox(height: 4),
                        Text(card.typeLine!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        children: [
                          if (card.priceUsd != null)
                            Text('\$${card.priceUsd}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: gold)),
                          if (card.priceEur != null)
                            Text('€${card.priceEur}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: gold)),
                        ],
                      ),
                      if (card.scryfallUri != null)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 36),
                          ),
                          onPressed: () => launchUrl(
                            Uri.parse(card.scryfallUri!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(l10n.openInScryfall),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (card.oracleText != null && card.oracleText!.isNotEmpty) ...[
              const Divider(height: 20),
              Text(card.oracleText!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 4),
            Text(
              ident.source == IdentificationSource.ocr
                  ? l10n.identifiedByOcr
                  : l10n.identifiedByAi,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 24),
            if (widget.autoAdded)
              Row(
                children: [
                  Icon(Icons.check_circle, color: gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.quickModeAdded,
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              )
            else
              _buildForm(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.quantity,
                  style: theme.textTheme.bodyMedium),
            ),
            IconButton(
              tooltip: l10n.decreaseQuantity,
              onPressed: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 32,
              child: Text('$_quantity',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
            ),
            IconButton(
              tooltip: l10n.increaseQuantity,
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.foil, style: theme.textTheme.bodyMedium),
          secondary: Icon(Icons.auto_awesome,
              color: _foil
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.outline),
          value: _foil,
          onChanged: (v) => setState(() => _foil = v),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Condition>(
                initialValue: _condition,
                decoration: InputDecoration(
                    labelText: l10n.conditionLabel, isDense: true),
                items: [
                  for (final c in Condition.values)
                    DropdownMenuItem(value: c, child: Text(c.code)),
                ],
                onChanged: (v) =>
                    setState(() => _condition = v ?? Condition.nm),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<Language>(
                initialValue: _language,
                decoration: InputDecoration(
                    labelText: l10n.languageLabel, isDense: true),
                items: [
                  for (final lang in Language.values)
                    DropdownMenuItem(value: lang, child: Text(lang.code)),
                ],
                onChanged: (v) =>
                    setState(() => _language = v ?? Language.en),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: Text(l10n.addToCollection),
        ),
      ],
    );
  }
}
