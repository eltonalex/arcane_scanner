import 'dart:typed_data';

/// Fases do ciclo de captura semi-automática.
enum StabilityPhase {
  /// Esperando a próxima carta chegar (precisa ver movimento primeiro).
  /// Isso evita disparar numa mesa vazia parada.
  waitingForMotion,

  /// Movimento detectado; aguardando a imagem estabilizar.
  stabilizing,

  /// Estável tempo suficiente — dispara a captura.
  triggered,

  /// Pós-captura: aguardando a carta ser retirada (movimento) para rearmar.
  cooldown,
}

/// Sinal emitido a cada frame processado.
class StabilitySignal {
  const StabilitySignal({required this.phase, required this.progress});

  final StabilityPhase phase;

  /// 0..1 — quão perto de disparar (para feedback visual do anel de progresso).
  final double progress;

  bool get shouldCapture => phase == StabilityPhase.triggered;
}

/// Detecta "carta parada no quadro" comparando assinaturas de luminância
/// entre frames consecutivos do preview.
///
/// Máquina de estados PURA e testável (recebe a diferença média já
/// calculada). A extração da assinatura a partir do CameraImage fica na
/// tela (parte dependente de plataforma).
///
/// Todos os limiares são ajustáveis — a calibragem varia por aparelho e
/// iluminação. Comece pelos padrões e ajuste no device.
class StabilityDetector {
  StabilityDetector({
    this.motionThreshold = 7.0,
    this.moveThreshold = 15.0,
    this.stillFramesNeeded = 5,
  });

  /// Abaixo desta diferença média de luma (0..255), consideramos "parado".
  final double motionThreshold;

  /// Acima desta diferença, consideramos "movimento" (carta entrando/saindo).
  final double moveThreshold;

  /// Frames parados consecutivos necessários para disparar (~ frames * intervalo).
  final int stillFramesNeeded;

  StabilityPhase _phase = StabilityPhase.waitingForMotion;
  int _stillCount = 0;

  StabilityPhase get phase => _phase;

  /// Alimenta a máquina com a diferença média entre o frame atual e o
  /// anterior. Retorna o sinal (fase + progresso + shouldCapture).
  StabilitySignal update(double avgDiff) {
    switch (_phase) {
      case StabilityPhase.waitingForMotion:
        if (avgDiff > moveThreshold) {
          _phase = StabilityPhase.stabilizing;
          _stillCount = 0;
        }

      case StabilityPhase.stabilizing:
        if (avgDiff > moveThreshold) {
          // Ainda mexendo: zera a contagem.
          _stillCount = 0;
        } else if (avgDiff < motionThreshold) {
          // Parado: conta.
          _stillCount++;
          if (_stillCount >= stillFramesNeeded) {
            _phase = StabilityPhase.triggered;
            return const StabilitySignal(
                phase: StabilityPhase.triggered, progress: 1);
          }
        }
      // Zona intermediária (entre os dois limiares): não conta nem zera.

      case StabilityPhase.triggered:
        // Aguarda o consumidor chamar armCooldown() após capturar.
        break;

      case StabilityPhase.cooldown:
        if (avgDiff > moveThreshold) {
          // Carta retirada / próxima chegando: rearma.
          _phase = StabilityPhase.waitingForMotion;
          _stillCount = 0;
        }
    }

    final progress = _phase == StabilityPhase.stabilizing
        ? (_stillCount / stillFramesNeeded).clamp(0.0, 1.0)
        : 0.0;
    return StabilitySignal(phase: _phase, progress: progress);
  }

  /// Chamado logo após disparar a captura: entra em cooldown até a carta
  /// sair de cena (evita recapturar a mesma carta).
  void armCooldown() {
    _phase = StabilityPhase.cooldown;
    _stillCount = 0;
  }

  /// Reinicia tudo (ao abrir a câmera ou trocar de modo).
  void reset() {
    _phase = StabilityPhase.waitingForMotion;
    _stillCount = 0;
  }
}

/// Extrai uma assinatura de luminância (grade NxN) do plano Y de um frame.
///
/// Puro: recebe os bytes do plano 0 e as dimensões, devolve a grade.
/// Em YUV420 (Android) o plano 0 é a luminância — ideal. Em BGRA (iOS)
/// lê um canal só, o que ainda serve como proxy de movimento.
Uint8List extractLumaSignature({
  required Uint8List planeBytes,
  required int bytesPerRow,
  required int width,
  required int height,
  int grid = 20,
}) {
  final sig = Uint8List(grid * grid);
  for (var gy = 0; gy < grid; gy++) {
    final y = (gy * height ~/ grid).clamp(0, height - 1);
    for (var gx = 0; gx < grid; gx++) {
      final x = (gx * width ~/ grid).clamp(0, width - 1);
      final idx = y * bytesPerRow + x;
      sig[gy * grid + gx] = idx < planeBytes.length ? planeBytes[idx] : 0;
    }
  }
  return sig;
}

/// Diferença média absoluta (0..255) entre duas assinaturas de mesmo tamanho.
double signatureDiff(Uint8List a, Uint8List b) {
  if (a.length != b.length || a.isEmpty) return 255;
  var sum = 0;
  for (var i = 0; i < a.length; i++) {
    sum += (a[i] - b[i]).abs();
  }
  return sum / a.length;
}
