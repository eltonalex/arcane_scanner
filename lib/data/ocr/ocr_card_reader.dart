import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/result.dart';
import '../../domain/models/card_identification.dart';
import 'ocr_text_parser.dart';

/// Lê o texto da imagem com ML Kit (on-device, grátis, offline) e
/// delega a extração de pistas ao parser puro.
///
/// Só funciona em Android/iOS — no web/desktop retorna falha e o
/// pipeline segue direto para a IA.
class OcrCardReader {
  Future<Result<CardIdentification>> read(String imagePath) async {
    if (kIsWeb) {
      return Result.err(
        const AppFailure('OCR local não está disponível no navegador.'),
      );
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(input);

      // Ordena os blocos de cima para baixo para o parser saber
      // o que é topo (nome) e o que é rodapé (set/número).
      final blocks = [...recognized.blocks]
        ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
      final lines = [
        for (final block in blocks)
          for (final line in block.lines) line.text,
      ];

      return Result.ok(parseOcrLines(lines));
    } catch (e) {
      return Result.err(
        AppFailure('Não foi possível ler o texto da imagem.', cause: e),
      );
    } finally {
      await recognizer.close();
    }
  }
}
