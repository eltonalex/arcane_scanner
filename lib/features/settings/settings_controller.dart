import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai/ai_config.dart';
import '../../data/collection_importer.dart';
import '../collection/collection_controller.dart';
import '../scan/scan_controller.dart';

// ---------------- Provedor de IA selecionado ----------------

class SelectedAiProviderNotifier extends AsyncNotifier<AiProvider> {
  @override
  Future<AiProvider> build() =>
      ref.read(aiConfigProvider).selectedProvider();

  Future<void> select(AiProvider provider) async {
    state = AsyncData(provider);
    await ref.read(aiConfigProvider).setSelectedProvider(provider);
    ref.invalidate(hasApiKeyProvider(provider));
  }
}

final selectedAiProviderProvider =
    AsyncNotifierProvider<SelectedAiProviderNotifier, AiProvider>(
        SelectedAiProviderNotifier.new);

/// Existe chave gravada para o provedor? (nunca expõe a chave em si)
final hasApiKeyProvider =
    FutureProvider.family<bool, AiProvider>((ref, provider) async {
  final key = await ref.read(aiConfigProvider).apiKeyFor(provider);
  return key != null && key.isNotEmpty;
});

// ---------------- Importação ----------------

final collectionImporterProvider = Provider<CollectionImporter>((ref) {
  return CollectionImporter(
    repository: ref.watch(collectionRepositoryProvider),
    scryfall: ref.watch(scryfallApiProvider),
  );
});

sealed class ImportState {
  const ImportState();
}

class ImportIdle extends ImportState {
  const ImportIdle();
}

class ImportRunning extends ImportState {
  const ImportRunning({this.done = 0, this.total = 0});
  final int done;
  final int total; // 0 = indeterminado (JSON)
}

class ImportDone extends ImportState {
  const ImportDone(this.report);
  final ImportReport report;
}

class ImportError extends ImportState {
  const ImportError(this.message);
  final String message;
}

class ImportController extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportIdle();

  Future<void> importJson(String content) async {
    state = const ImportRunning();
    final result =
        await ref.read(collectionImporterProvider).importJson(content);
    state = result.when(
      ok: (report) => ImportDone(report),
      err: (f) => ImportError(f.message),
    );
  }

  Future<void> importCsv(String content) async {
    state = const ImportRunning();
    final result = await ref.read(collectionImporterProvider).importCsv(
          content,
          onProgress: (done, total) =>
              state = ImportRunning(done: done, total: total),
        );
    state = result.when(
      ok: (report) => ImportDone(report),
      err: (f) => ImportError(f.message),
    );
  }

  void reset() => state = const ImportIdle();
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);
