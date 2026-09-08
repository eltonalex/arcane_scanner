import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../data/image/card_cropper.dart';

/// Moldura-guia sobreposta ao preview da câmera: escurece o entorno,
/// desenha o contorno da carta (proporção oficial) e destaca a faixa
/// onde o rodapé (set + collector number) deve ficar.
class CardGuideOverlay extends StatelessWidget {
  const CardGuideOverlay({super.key, this.highlight = false});

  /// Quando true (modo automático estabilizando), realça a moldura.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GuidePainter(highlight: highlight),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter({required this.highlight});

  final bool highlight;

  static const _gold = ArcanePalette.mysticGold;

  @override
  void paint(Canvas canvas, Size size) {
    // Retângulo da carta: centralizado, proporção oficial, mesma fração
    // de altura usada no recorte (WYSIWYG aproximado).
    var cardH = size.height * kCardHeightFraction;
    var cardW = cardH * kCardAspectRatio;
    if (cardW > size.width * 0.92) {
      cardW = size.width * 0.92;
      cardH = cardW / kCardAspectRatio;
    }
    final left = (size.width - cardW) / 2;
    final top = (size.height - cardH) / 2;
    final cardRect = Rect.fromLTWH(left, top, cardW, cardH);
    final rrect =
        RRect.fromRectAndRadius(cardRect, const Radius.circular(14));

    // Escurece tudo, menos a área da carta.
    final scrim = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Contorno da carta (mais forte quando estabilizando no modo auto).
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlight ? 4 : 2
        ..color = _gold.withValues(alpha: highlight ? 1 : 0.9),
    );

    // Faixa do rodapé.
    final footerH = cardH * kFooterHeightFraction;
    final footerTop = cardRect.bottom - footerH;
    final footerRect =
        Rect.fromLTWH(cardRect.left, footerTop, cardW, footerH);
    canvas.drawRect(
      footerRect,
      Paint()..color = _gold.withValues(alpha: 0.12),
    );
    canvas.drawLine(
      Offset(cardRect.left, footerTop),
      Offset(cardRect.right, footerTop),
      Paint()
        ..strokeWidth = 1.5
        ..color = _gold.withValues(alpha: 0.7),
    );

    // Cantos em "L" para reforçar o alvo.
    _drawCorners(canvas, cardRect);

    // Rótulo do rodapé.
    _drawLabel(canvas, 'rodapé', footerRect.center);
  }

  void _drawCorners(Canvas canvas, Rect r) {
    const len = 22.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = _gold;

    void corner(Offset p, Offset h, Offset v) {
      canvas.drawLine(p, p + h, paint);
      canvas.drawLine(p, p + v, paint);
    }

    corner(r.topLeft, const Offset(len, 0), const Offset(0, len));
    corner(r.topRight, const Offset(-len, 0), const Offset(0, len));
    corner(r.bottomLeft, const Offset(len, 0), const Offset(0, -len));
    corner(r.bottomRight, const Offset(-len, 0), const Offset(0, -len));
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _gold.withValues(alpha: 0.85),
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GuidePainter oldDelegate) =>
      oldDelegate.highlight != highlight;
}
