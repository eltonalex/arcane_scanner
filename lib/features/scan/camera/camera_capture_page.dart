import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/image/card_cropper.dart';
import '../../../l10n/app_localizations.dart';
import '../scan_controller.dart';
import '../scan_queue.dart';
import '../review/review_page.dart';
import 'card_guide_overlay.dart';
import 'stability_detector.dart';

/// Resultado devolvido à tela de scan após capturar e recortar (modo manual).
class CameraCaptureResult {
  const CameraCaptureResult({
    required this.cardImagePath,
    required this.footerImagePath,
  });

  final String cardImagePath;
  final String footerImagePath;
}

/// Resolução da captura. veryHigh (~1080p) equilibra nitidez do rodapé e
/// velocidade de recorte no isolate. Suba para `max` se o OCR do rodapé
/// ficar marginal no seu aparelho (custa mais memória/tempo).
const ResolutionPreset kCaptureResolution = ResolutionPreset.veryHigh;

/// Intervalo mínimo entre frames processados no modo automático (throttle).
/// Menor = mais responsivo e mais custoso. Ajuste fino se travar.
const Duration kFrameInterval = Duration(milliseconds: 120);

class CameraCapturePage extends ConsumerStatefulWidget {
  const CameraCapturePage({super.key});

  @override
  ConsumerState<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends ConsumerState<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  final _cropper = const CardCropper();

  bool _torchOn = false;
  bool _capturing = false;
  String? _error;

  // ---- Modo automático (semi-auto por estabilidade) ----
  bool _autoMode = false;
  bool _streaming = false;
  bool _busy = false; // capturando/identificando/confirmando
  final _detector = StabilityDetector();
  Uint8List? _prevSignature;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);
  double _progress = 0;
  StabilityPhase _phase = StabilityPhase.waitingForMotion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'noCamera');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        kCaptureResolution,
        enableAudio: false,
        // yuv420 é o formato do stream no Android; takePicture segue
        // gerando JPEG normalmente.
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } on CameraException {
      if (mounted) setState(() => _error = 'denied');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      _streaming = false;
    } else if (state == AppLifecycleState.resumed) {
      _setup().then((_) {
        if (_autoMode) _startStream();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final next = !_torchOn;
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    setState(() => _torchOn = next);
  }

  // ---------------- Modo automático ----------------

  Future<void> _toggleAutoMode() async {
    final next = !_autoMode;
    setState(() => _autoMode = next);
    if (next) {
      _detector.reset();
      _prevSignature = null;
      await _startStream();
    } else {
      await _stopStream();
      setState(() {
        _phase = StabilityPhase.waitingForMotion;
        _progress = 0;
      });
    }
  }

  Future<void> _startStream() async {
    final controller = _controller;
    if (controller == null || _streaming) return;
    _streaming = true;
    await controller.startImageStream(_onFrame);
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null || !_streaming) return;
    _streaming = false;
    await controller.stopImageStream();
  }

  void _onFrame(CameraImage image) {
    if (_busy) return;
    final now = DateTime.now();
    if (now.difference(_lastFrame) < kFrameInterval) return;
    _lastFrame = now;

    final plane = image.planes.first;
    final sig = extractLumaSignature(
      planeBytes: plane.bytes,
      bytesPerRow: plane.bytesPerRow,
      width: image.width,
      height: image.height,
    );

    final prev = _prevSignature;
    _prevSignature = sig;
    if (prev == null) return; // primeiro frame, sem referência

    final diff = signatureDiff(prev, sig);
    final signal = _detector.update(diff);

    if (signal.phase != _phase || signal.progress != _progress) {
      if (mounted) {
        setState(() {
          _phase = signal.phase;
          _progress = signal.progress;
        });
      }
    }

    if (signal.shouldCapture) {
      _detector.armCooldown();
      _autoCaptureAndEnqueue();
    }
  }

  /// Fluxo automático: para o stream, captura, recorta, identifica e
  /// ENFILEIRA para revisão em lote. Ao terminar, rearma para a próxima.
  Future<void> _autoCaptureAndEnqueue() async {
    if (_busy) return;
    _busy = true;
    unawaited(SystemSound.play(SystemSoundType.click));
    unawaited(HapticFeedback.mediumImpact());

    final controller = _controller;
    if (controller == null) {
      _busy = false;
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await _stopStream();
      if (mounted) setState(() => _capturing = true);

      final shot = await controller.takePicture();
      final crop = await _cropper.cropCapture(shot.path);

      final service = ref.read(identificationServiceProvider);
      final bytes = await XFile(crop.cardImagePath).readAsBytes();
      final result = await service.identify(
        imagePath: crop.cardImagePath,
        compressedJpeg: bytes,
        footerImagePath: crop.footerImagePath,
      );

      if (!mounted) return;
      setState(() => _capturing = false);

      result.when(
        ok: (identified) {
          // Enfileira para revisão em lote e rearma para a próxima carta.
          ref.read(scanQueueProvider.notifier).add(identified);
          messenger.showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 900),
            content: Text(l10n.queuedCard(identified.card.name)),
          ));
        },
        err: (failure) {
          messenger.showSnackBar(SnackBar(content: Text(failure.message)));
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _capturing = false);
        messenger.showSnackBar(SnackBar(content: Text(l10n.cameraError)));
      }
    } finally {
      _busy = false;
      _prevSignature = null; // evita falso "parado" logo após retomar
      if (_autoMode && mounted) await _startStream();
    }
  }

  // ---------------- Modo manual (botão) ----------------

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);

    unawaited(SystemSound.play(SystemSoundType.click));
    unawaited(HapticFeedback.mediumImpact());

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final shot = await controller.takePicture();
      final result = await _cropper.cropCapture(shot.path);
      navigator.pop(CameraCaptureResult(
        cardImagePath: result.cardImagePath,
        footerImagePath: result.footerImagePath,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _capturing = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.cameraError)));
    }
  }

  Future<void> _openReview() async {
    await _stopStream();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReviewPage()),
    );
    // Voltou da revisão: rearma se o modo automático seguir ligado.
    if (_autoMode && mounted) {
      _detector.reset();
      _prevSignature = null;
      await _startStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_error != null) {
      return _ErrorView(
        message:
            _error == 'denied' ? l10n.cameraPermissionDenied : l10n.cameraError,
        onBack: () => Navigator.of(context).pop(),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final queueCount = ref.watch(scanQueueProvider).length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraFill(controller: controller),
          CardGuideOverlay(
            highlight: _autoMode && _phase == StabilityPhase.stabilizing,
          ),
          _TopBar(
            torchOn: _torchOn,
            autoMode: _autoMode,
            onClose: () => Navigator.of(context).pop(),
            onToggleTorch: _toggleTorch,
            onToggleAuto: _toggleAutoMode,
          ),
          if (queueCount > 0)
            _ReviewChip(count: queueCount, onTap: _openReview),
          _BottomBar(
            hint: _autoMode ? _autoHint(l10n) : l10n.cameraAlignHint,
            autoMode: _autoMode,
            capturing: _capturing,
            progress: _progress,
            onCapture: _capture,
          ),
          if (_capturing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.cameraProcessing,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _autoHint(AppLocalizations l10n) => switch (_phase) {
        StabilityPhase.waitingForMotion => l10n.autoWaiting,
        StabilityPhase.stabilizing => l10n.autoHold,
        StabilityPhase.cooldown => l10n.autoSwap,
        StabilityPhase.triggered => l10n.cameraProcessing,
      };
}

/// Preenche a tela com o preview (cover), corrigindo a proporção em
/// retrato. Ponto de ajuste fino se o preview aparecer esticado.
class _CameraFill extends StatelessWidget {
  const _CameraFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(controller)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.torchOn,
    required this.autoMode,
    required this.onClose,
    required this.onToggleTorch,
    required this.onToggleAuto,
  });

  final bool torchOn;
  final bool autoMode;
  final VoidCallback onClose;
  final VoidCallback onToggleTorch;
  final VoidCallback onToggleAuto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gold = Theme.of(context).colorScheme.secondary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
            Row(
              children: [
                Semantics(
                  button: true,
                  label: l10n.autoMode,
                  child: TextButton.icon(
                    onPressed: onToggleAuto,
                    icon: Icon(
                      autoMode
                          ? Icons.motion_photos_on
                          : Icons.motion_photos_off,
                      color: autoMode ? gold : Colors.white,
                    ),
                    label: Text(
                      l10n.autoMode,
                      style: TextStyle(color: autoMode ? gold : Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.cameraTorch,
                  icon: Icon(
                    torchOn ? Icons.flash_on : Icons.flash_off,
                    color: torchOn ? gold : Colors.white,
                  ),
                  onPressed: onToggleTorch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.hint,
    required this.autoMode,
    required this.capturing,
    required this.progress,
    required this.onCapture,
  });

  final String hint;
  final bool autoMode;
  final bool capturing;
  final double progress;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gold = Theme.of(context).colorScheme.secondary;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              if (autoMode)
                SizedBox(
                  width: 74,
                  height: 74,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: CircularProgressIndicator(
                          value: progress == 0 ? null : progress,
                          strokeWidth: 4,
                          color: gold,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Icon(Icons.motion_photos_on, color: gold, size: 30),
                    ],
                  ),
                )
              else
                Semantics(
                  button: true,
                  label: l10n.cameraCapture,
                  child: GestureDetector(
                    onTap: capturing ? null : onCapture,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                        border: Border.all(color: gold, width: 4),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contador da fila + atalho para a tela de revisão (canto superior).
class _ReviewChip extends StatelessWidget {
  const _ReviewChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Material(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_add_check,
                        size: 18, color: theme.colorScheme.onSecondary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.reviewChip(count),
                      style: TextStyle(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 56),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: onBack, child: Text(l10n.back)),
            ],
          ),
        ),
      ),
    );
  }
}
