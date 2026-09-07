import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai/ai_config.dart';
import '../../l10n/app_localizations.dart';
import '../scan/scan_controller.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _keyController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey(AiProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final key = _keyController.text.trim();
    await ref.read(aiConfigProvider).setApiKey(provider, key);
    ref.invalidate(hasApiKeyProvider(provider));
    _keyController.clear();
    messenger.showSnackBar(
      SnackBar(content: Text(key.isEmpty ? l10n.keyRemoved : l10n.keySaved)),
    );
  }

  Future<void> _pickAndImport({required bool json}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [json ? 'json' : 'csv'],
      withData: true,
    );
    final bytes = picked?.files.single.bytes;
    if (bytes == null) return; // cancelado

    final content = utf8.decode(bytes, allowMalformed: true);
    final controller = ref.read(importControllerProvider.notifier);
    if (json) {
      await controller.importJson(content);
    } else {
      await controller.importCsv(content);
    }

    final state = ref.read(importControllerProvider);
    if (state is ImportDone) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.importDone(
            state.report.imported, state.report.failed)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = ref.watch(selectedAiProviderProvider).valueOrNull ??
        AiProvider.openai;
    final hasKey =
        ref.watch(hasApiKeyProvider(provider)).valueOrNull ?? false;
    final importState = ref.watch(importControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- IA (fallback) ----------------
          Text(l10n.settingsAiSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.aiSectionHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          DropdownButtonFormField<AiProvider>(
            initialValue: provider,
            decoration:
                InputDecoration(labelText: l10n.aiProviderLabel, isDense: true),
            items: [
              for (final p in AiProvider.values)
                DropdownMenuItem(value: p, child: Text(p.label)),
            ],
            onChanged: (p) {
              if (p != null) {
                ref.read(selectedAiProviderProvider.notifier).select(p);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                hasKey ? Icons.check_circle : Icons.key_off,
                size: 18,
                color: hasKey
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(hasKey ? l10n.keyConfigured : l10n.keyNotConfigured,
                  style: theme.textTheme.bodySmall),
              const Spacer(),
              if (hasKey)
                TextButton(
                  onPressed: () {
                    _keyController.clear();
                    _saveKey(provider);
                  },
                  child: Text(l10n.removeKey),
                ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.apiKeyLabel,
              hintText: l10n.apiKeyHint,
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _saveKey(provider),
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.saveKey),
          ),

          const Divider(height: 40),

          // ---------------- Importação ----------------
          Text(l10n.importSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.importHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          switch (importState) {
            ImportRunning(:final done, :final total) => Column(
                children: [
                  LinearProgressIndicator(
                    value: total > 0 ? done / total : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total > 0
                        ? l10n.importProgress(done, total)
                        : l10n.importing,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            _ => Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickAndImport(json: true),
                      icon: const Icon(Icons.data_object, size: 18),
                      label: Text(l10n.importJson),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickAndImport(json: false),
                      icon: const Icon(Icons.table_chart_outlined, size: 18),
                      label: Text(l10n.importCsv),
                    ),
                  ),
                ],
              ),
          },
          if (importState case ImportDone(:final report)) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.importDone(report.imported, report.failed)),
                    for (final error in report.errors)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(error,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error)),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (importState case ImportError(:final message)) ...[
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
