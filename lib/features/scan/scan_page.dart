import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import 'camera/camera_capture_page.dart';
import 'review/review_page.dart';
import 'scan_controller.dart';
import 'scan_queue.dart';
import 'widgets/card_result_panel.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final quickMode = ref.watch(quickModeProvider).valueOrNull ?? false;

    Future<void> openCamera() async {
      final result = await Navigator.of(context).push<CameraCaptureResult>(
        MaterialPageRoute(builder: (_) => const CameraCapturePage()),
      );
      if (result != null) {
        await controller.onCameraCaptured(
          cardImagePath: result.cardImagePath,
          footerImagePath: result.footerImagePath,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (state is! ScanIdle)
            IconButton(
              tooltip: l10n.newScan,
              icon: const Icon(Icons.refresh),
              onPressed: controller.reset,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Banner de fila pendente (capturas ainda não confirmadas).
            if (ref.watch(scanQueueProvider).isNotEmpty)
              Material(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: Icon(Icons.inventory_2_outlined,
                      color: theme.colorScheme.onSecondaryContainer),
                  title: Text(
                    l10n.pendingQueueBanner(
                        ref.watch(scanQueueProvider).length),
                    style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer),
                  ),
                  trailing: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReviewPage()),
                    ),
                    child: Text(l10n.reviewAction),
                  ),
                ),
              ),
            // Toggle do modo rápido
            SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              title: Text(l10n.quickMode),
              subtitle: Text(l10n.quickModeSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              secondary: Icon(Icons.bolt,
                  color: quickMode
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.outline),
              value: quickMode,
              onChanged: (v) =>
                  ref.read(quickModeProvider.notifier).toggle(v),
            ),
            const Divider(height: 1),
            ...switch (state) {
              ScanIdle() => [_IdlePanel(onPick: controller.pickImage, onCamera: openCamera)],
              ScanImageReady(:final imagePath) => [
                  _ImagePreview(imagePath: imagePath),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: FilledButton.icon(
                      onPressed: controller.identify,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(l10n.identifyButton),
                    ),
                  ),
                  _PickAgainRow(onPick: controller.pickImage, onCamera: openCamera),
                ],
              ScanIdentifying(:final imagePath) => [
                  _ImagePreview(imagePath: imagePath),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  Center(
                    child: Text(l10n.identifying,
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ScanSuccess(:final result, :final autoAdded) => [
                  CardResultPanel(result: result, autoAdded: autoAdded),
                  _PickAgainRow(onPick: controller.pickImage, onCamera: openCamera),
                ],
              ScanFailure(:final imagePath, :final message) => [
                  _ImagePreview(imagePath: imagePath),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: theme.colorScheme.error.withValues(alpha: 0.12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(message,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: controller.identify,
                              icon: const Icon(Icons.replay),
                              label: Text(l10n.tryAgain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _PickAgainRow(onPick: controller.pickImage, onCamera: openCamera),
                ],
            },
          ],
        ),
      ),
    );
  }
}

class _IdlePanel extends StatelessWidget {
  const _IdlePanel({required this.onPick, required this.onCamera});

  final void Function(ImageSource source) onPick;
  final Future<void> Function() onCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.auto_awesome,
              size: 56, color: theme.colorScheme.secondary),
          const SizedBox(height: 16),
          Text(l10n.scanHeadline,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l10n.scanSubtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          if (!kIsWeb)
            FilledButton.icon(
              onPressed: onCamera,
              icon: const Icon(Icons.photo_camera),
              label: Text(l10n.scanCameraButton),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => onPick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.scanGalleryButton),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: kIsWeb
              ? Image.network(imagePath, fit: BoxFit.contain)
              : Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _PickAgainRow extends StatelessWidget {
  const _PickAgainRow({required this.onPick, required this.onCamera});

  final void Function(ImageSource source) onPick;
  final Future<void> Function() onCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          if (!kIsWeb)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCamera,
                icon: const Icon(Icons.photo_camera, size: 18),
                label: Text(l10n.scanCameraButton),
              ),
            ),
          if (!kIsWeb) const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(l10n.scanGalleryButton),
            ),
          ),
        ],
      ),
    );
  }
}
