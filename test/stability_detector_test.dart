import 'dart:typed_data';

import 'package:arcane_scanner/features/scan/camera/stability_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StabilityDetector (máquina de estados)', () {
    test('não dispara em cena parada sem movimento prévio', () {
      final d = StabilityDetector(stillFramesNeeded: 3);
      // Mesa vazia parada: várias leituras baixas, nunca arma.
      for (var i = 0; i < 10; i++) {
        final s = d.update(1.0);
        expect(s.shouldCapture, isFalse);
        expect(s.phase, StabilityPhase.waitingForMotion);
      }
    });

    test('dispara após movimento seguido de estabilidade', () {
      final d = StabilityDetector(
          stillFramesNeeded: 3, motionThreshold: 7, moveThreshold: 15);
      // Carta chegando (movimento).
      expect(d.update(40).phase, StabilityPhase.stabilizing);
      // Estabilizando: 3 frames parados.
      expect(d.update(2).shouldCapture, isFalse);
      expect(d.update(2).shouldCapture, isFalse);
      expect(d.update(2).shouldCapture, isTrue); // 3º frame parado -> dispara
    });

    test('movimento no meio da estabilização zera a contagem', () {
      final d = StabilityDetector(stillFramesNeeded: 3);
      d.update(40); // entra em stabilizing
      d.update(2); // 1
      d.update(2); // 2
      d.update(40); // mexeu de novo -> zera
      expect(d.update(2).shouldCapture, isFalse); // seria 3, mas zerou
      expect(d.update(2).shouldCapture, isFalse);
      expect(d.update(2).shouldCapture, isTrue);
    });

    test('cooldown exige carta sair antes de rearmar', () {
      final d = StabilityDetector(stillFramesNeeded: 2);
      d.update(40);
      d.update(2);
      final trig = d.update(2);
      expect(trig.shouldCapture, isTrue);

      d.armCooldown();
      // Mesma carta ainda parada: não redispara.
      for (var i = 0; i < 5; i++) {
        expect(d.update(2).shouldCapture, isFalse);
      }
      // Carta retirada (movimento) -> volta a esperar a próxima.
      expect(d.update(40).phase, StabilityPhase.waitingForMotion);
    });

    test('progress cresce durante a estabilização', () {
      final d = StabilityDetector(stillFramesNeeded: 4);
      d.update(40);
      expect(d.update(2).progress, closeTo(0.25, 0.001));
      expect(d.update(2).progress, closeTo(0.5, 0.001));
    });
  });

  group('assinatura de luminância', () {
    test('diferença zero para bytes idênticos', () {
      final a = Uint8List.fromList(List.filled(400, 128));
      final b = Uint8List.fromList(List.filled(400, 128));
      expect(signatureDiff(a, b), 0);
    });

    test('diferença média correta', () {
      final a = Uint8List.fromList(List.filled(4, 100));
      final b = Uint8List.fromList(List.filled(4, 110));
      expect(signatureDiff(a, b), 10);
    });

    test('extractLumaSignature respeita a grade e os limites', () {
      // "Imagem" 100x100, todos os bytes = 50 (rowStride = width).
      final bytes = Uint8List.fromList(List.filled(100 * 100, 50));
      final sig = extractLumaSignature(
        planeBytes: bytes,
        bytesPerRow: 100,
        width: 100,
        height: 100,
        grid: 10,
      );
      expect(sig.length, 100); // 10x10
      expect(sig.every((v) => v == 50), isTrue);
    });
  });
}
