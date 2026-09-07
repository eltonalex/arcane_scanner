import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Proporção oficial de uma carta de Magic: 63mm de largura por 88mm de
/// altura. Usada tanto na moldura-guia (UI) quanto no recorte.
const double kCardAspectRatio = 63 / 88; // ~0.7159 (largura / altura)

/// Fração da ALTURA da imagem ocupada pela carta na moldura-guia.
/// Conservadora de propósito: com o preview em "cover", uma moldura um
/// pouco menor garante que o recorte central contenha a carta mesmo com
/// leve desalinhamento. Ajuste fino no device.
const double kCardHeightFraction = 0.80;

/// Fração da ALTURA DA CARTA ocupada pela faixa do rodapé (set +
/// collector number). Generosa para não perder o rodapé por 1-2mm.
const double kFooterHeightFraction = 0.18;

/// Retângulo de recorte em pixels inteiros, já validado nos limites.
@immutable
class CropRect {
  const CropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is CropRect &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'CropRect(x:$x, y:$y, w:$width, h:$height)';
}

/// Geometria PURA e testável: dada uma imagem WxH, calcula o retângulo
/// da carta (centralizada, proporção oficial) e o da faixa do rodapé.
@immutable
class CardCropGeometry {
  const CardCropGeometry({required this.card, required this.footer});

  final CropRect card;
  final CropRect footer;

  factory CardCropGeometry.forImage(
    int imageWidth,
    int imageHeight, {
    double cardHeightFraction = kCardHeightFraction,
    double footerHeightFraction = kFooterHeightFraction,
    double cardAspectRatio = kCardAspectRatio,
  }) {
    // Carta centralizada; altura = fração da altura da imagem.
    var cardH = (imageHeight * cardHeightFraction).round();
    var cardW = (cardH * cardAspectRatio).round();

    // Se estourar a largura, limita pela largura e recalcula a altura.
    if (cardW > imageWidth) {
      cardW = (imageWidth * 0.96).round();
      cardH = (cardW / cardAspectRatio).round();
    }

    final cardX = ((imageWidth - cardW) / 2).round();
    final cardY = ((imageHeight - cardH) / 2).round();

    final footerH = (cardH * footerHeightFraction).round();
    final footerY = cardY + cardH - footerH;

    return CardCropGeometry(
      card: _clamp(
          CropRect(x: cardX, y: cardY, width: cardW, height: cardH),
          imageWidth,
          imageHeight),
      footer: _clamp(
          CropRect(x: cardX, y: footerY, width: cardW, height: footerH),
          imageWidth,
          imageHeight),
    );
  }

  static CropRect _clamp(CropRect r, int w, int h) {
    final x = r.x.clamp(0, w - 1);
    final y = r.y.clamp(0, h - 1);
    return CropRect(
      x: x,
      y: y,
      width: r.width.clamp(1, w - x),
      height: r.height.clamp(1, h - y),
    );
  }
}

/// Resultado do recorte: caminhos dos dois JPEGs gerados.
class CardCropResult {
  const CardCropResult({
    required this.cardImagePath,
    required this.footerImagePath,
  });

  final String cardImagePath; // carta inteira (para exibir + IA)
  final String footerImagePath; // faixa do rodapé (para OCR de precisão)
}

/// Recorta a foto capturada em duas imagens (carta + rodapé). O trabalho
/// pesado de decodificar/recortar/encodar roda em um isolate (compute)
/// para não travar a UI.
class CardCropper {
  const CardCropper();

  Future<CardCropResult> cropCapture(String sourcePath) async {
    final paths = await compute(_cropInIsolate, sourcePath);
    return CardCropResult(
      cardImagePath: paths[0],
      footerImagePath: paths[1],
    );
  }
}

/// Executado em outro isolate. Retorna [cardPath, footerPath].
Future<List<String>> _cropInIsolate(String sourcePath) async {
  final bytes = await File(sourcePath).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Não foi possível decodificar a imagem.');
  }

  // Normaliza a orientação EXIF para o recorte bater com o que o
  // usuário viu no preview.
  final image = img.bakeOrientation(decoded);
  final geo = CardCropGeometry.forImage(image.width, image.height);

  final card = img.copyCrop(
    image,
    x: geo.card.x,
    y: geo.card.y,
    width: geo.card.width,
    height: geo.card.height,
  );
  final footer = img.copyCrop(
    image,
    x: geo.footer.x,
    y: geo.footer.y,
    width: geo.footer.width,
    height: geo.footer.height,
  );

  final dir = File(sourcePath).parent.path;
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final cardPath = '$dir/card_$stamp.jpg';
  final footerPath = '$dir/footer_$stamp.jpg';

  await File(cardPath).writeAsBytes(img.encodeJpg(card, quality: 92));
  // Rodapé em qualidade alta: é a base do OCR de precisão.
  await File(footerPath).writeAsBytes(img.encodeJpg(footer, quality: 95));

  return [cardPath, footerPath];
}
