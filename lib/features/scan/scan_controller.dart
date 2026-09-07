import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/result.dart';
import '../../data/ai/ai_config.dart';
import '../../data/card_identification_service.dart';
import '../../data/ocr/ocr_card_reader.dart';
import '../../data/scryfall_api.dart';
import '../../domain/models/collection_entry.dart';
import '../../domain/models/condition.dart';
import '../../domain/models/language.dart';
import '../collection/collection_controller.dart';

// ---------------- Providers de infraestrutura ----------------

final scryfallApiProvider = Provider<ScryfallApi>((ref) => ScryfallApi());
final aiConfigProvider =
    Provider<AiConfigRepository>((ref) => AiConfigRepository());

final identificationServiceProvider =
    Provider<CardIdentificationService>((ref) {
  return CardIdentificationService(
    ocr: OcrCardReader(),
    scryfall: ref.watch(scryfallApiProvider),
    aiConfig: ref.watch(aiConfigProvider),
  );
});

// ---------------- Modo rápido (SharedPreferences) ----------------

class QuickModeNotifier extends AsyncNotifier<bool> {
  static const _prefKey = 'quick_mode';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> toggle(bool value) async {
    state = AsyncData(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}

final quickModeProvider =
    AsyncNotifierProvider<QuickModeNotifier, bool>(QuickModeNotifier.new);

// ---------------- Estado da tela de scan ----------------

sealed class ScanState {
  const ScanState();
}

class ScanIdle extends ScanState {
  const ScanIdle();
}

class ScanImageReady extends ScanState {
  const ScanImageReady({required this.imagePath});
  final String imagePath;
}

class ScanIdentifying extends ScanState {
  const ScanIdentifying({required this.imagePath});
  final String imagePath;
}

class ScanSuccess extends ScanState {
  const ScanSuccess({
    required this.imagePath,
    required this.result,
    this.autoAdded = false,
  });

  final String imagePath;
  final IdentifiedCard result;

  /// true quando o modo rápido já adicionou 1x à coleção.
  final bool autoAdded;
}

class ScanFailure extends ScanState {
  const ScanFailure({required this.imagePath, required this.message});
  final String imagePath;
  final String message;
}

// ---------------- Controller ----------------

class ScanController extends Notifier<ScanState> {
  final _picker = ImagePicker();

  /// Caminho da faixa do rodapé recortada pela câmera (OCR de precisão).
  /// Null quando a imagem veio da galeria/picker.
  String? _footerImagePath;

  @override
  ScanState build() => const ScanIdle();

  Future<void> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      // O picker já limita a resolução — economiza a etapa de resize
      // na maioria dos casos; a compressão abaixo garante o teto.
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 92,
    );
    if (file == null) return; // usuário cancelou
    _footerImagePath = null; // galeria/picker não tem rodapé recortado
    state = ScanImageReady(imagePath: file.path);
  }

  /// Chamado pela tela de câmera após capturar e recortar. Recebe a
  /// carta recortada e a faixa do rodapé, e já dispara a identificação.
  Future<void> onCameraCaptured({
    required String cardImagePath,
    required String footerImagePath,
  }) async {
    _footerImagePath = footerImagePath;
    state = ScanImageReady(imagePath: cardImagePath);
    await identify();
  }

  Future<void> identify() async {
    final current = state;
    final imagePath = switch (current) {
      ScanImageReady(:final imagePath) => imagePath,
      ScanFailure(:final imagePath) => imagePath, // retry manual
      ScanSuccess(:final imagePath) => imagePath,
      _ => null,
    };
    if (imagePath == null) return;

    state = ScanIdentifying(imagePath: imagePath);

    final compressed = await _compress(imagePath);
    final service = ref.read(identificationServiceProvider);
    final result = await service.identify(
      imagePath: imagePath,
      compressedJpeg: compressed,
      footerImagePath: _footerImagePath,
    );

    switch (result) {
      case Err(:final failure):
        state = ScanFailure(imagePath: imagePath, message: failure.message);
      case Ok(value: final identified):
        var autoAdded = false;
        if (ref.read(quickModeProvider).valueOrNull ?? false) {
          await addToCollection(identified);
          autoAdded = true;
        }
        state = ScanSuccess(
          imagePath: imagePath,
          result: identified,
          autoAdded: autoAdded,
        );
    }
  }

  /// Comprime/redimensiona para no máx. 1600px no maior lado antes
  /// de enviar à IA (menos tokens, upload mais rápido).
  Future<Uint8List> _compress(String path) async {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: 1600,
      minHeight: 1600,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    if (result != null) return result;
    // Fallback: usa o arquivo como está (o picker já limitou a 1600px).
    return XFile(path).readAsBytes();
  }

  Future<void> addToCollection(
    IdentifiedCard identified, {
    int quantity = 1,
    bool foil = false,
    Condition condition = Condition.nm,
    Language? language,
  }) async {
    final card = identified.card;
    final entry = CollectionEntry(
      scryfallId: card.id,
      name: card.name,
      setCode: card.setCode,
      setName: card.setName,
      collectorNumber: card.collectorNumber,
      rarity: card.rarity,
      imageUrl: card.imageSmall ?? card.imageNormal,
      scryfallUri: card.scryfallUri,
      quantity: quantity,
      foil: foil,
      condition: condition,
      language:
          language ?? identified.identification.language ?? Language.en,
      priceUsdAtAdd: card.priceUsd,
      priceEurAtAdd: card.priceEur,
      addedAt: DateTime.now().toUtc(),
    );
    await ref.read(collectionRepositoryProvider).add(entry);
  }

  void reset() {
    _footerImagePath = null;
    state = const ScanIdle();
  }
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);
