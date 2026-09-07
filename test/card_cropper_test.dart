import 'package:arcane_scanner/data/image/card_cropper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardCropGeometry', () {
    test('carta centralizada com a proporção oficial', () {
      // Imagem retrato típica (~1080x1920).
      final geo = CardCropGeometry.forImage(1080, 1920);

      // Proporção largura/altura ~ 0.716.
      final ratio = geo.card.width / geo.card.height;
      expect(ratio, closeTo(kCardAspectRatio, 0.01));

      // Centralizada horizontalmente.
      final centerX = geo.card.x + geo.card.width / 2;
      expect(centerX, closeTo(1080 / 2, 2));

      // Altura ~ 80% da altura da imagem.
      expect(geo.card.height, closeTo(1920 * kCardHeightFraction, 2));
    });

    test('faixa do rodapé fica na base da carta', () {
      final geo = CardCropGeometry.forImage(1080, 1920);

      // Mesma largura e X da carta.
      expect(geo.footer.width, geo.card.width);
      expect(geo.footer.x, geo.card.x);

      // Base do rodapé == base da carta.
      final cardBottom = geo.card.y + geo.card.height;
      final footerBottom = geo.footer.y + geo.footer.height;
      expect(footerBottom, closeTo(cardBottom, 2));

      // Altura do rodapé ~ 18% da altura da carta.
      expect(geo.footer.height,
          closeTo(geo.card.height * kFooterHeightFraction, 2));
    });

    test('limita pela largura em imagem quadrada (não estoura)', () {
      final geo = CardCropGeometry.forImage(1000, 1000);
      expect(geo.card.width, lessThanOrEqualTo(1000));
      expect(geo.card.x, greaterThanOrEqualTo(0));
      expect(geo.card.x + geo.card.width, lessThanOrEqualTo(1000));
    });

    test('todos os retângulos ficam dentro dos limites da imagem', () {
      for (final (w, h) in [(1080, 1920), (720, 1280), (3000, 4000)]) {
        final geo = CardCropGeometry.forImage(w, h);
        for (final r in [geo.card, geo.footer]) {
          expect(r.x, greaterThanOrEqualTo(0));
          expect(r.y, greaterThanOrEqualTo(0));
          expect(r.x + r.width, lessThanOrEqualTo(w));
          expect(r.y + r.height, lessThanOrEqualTo(h));
        }
      }
    });
  });
}
