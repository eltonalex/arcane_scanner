import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/image/card_cropper.dart';
import '../../../l10n/app_localizations.dart';
import 'card_guide_overlay.dart';

/// Resultado devolvido à tela de scan após capturar e recortar.
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

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  final _cropper = const CardCropper();

  bool _torchOn = false;
  bool _capturing = false;
  String? _error;

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
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _initFuture = controller.initialize();
      await _initFuture;
      if (!mounted) return;
      setState(() => _controller = controller);
    } on CameraException {
      // Permissão negada ou câmera indisponível.
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
    } else if (state == AppLifecycleState.resumed) {
      _setup();
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

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);

    // Feedback imediato de captura, sem dependências nem arquivos de áudio:
    // som de clique do sistema + leve vibração (a "sensação de foto").
    // Obs.: o clique respeita o ajuste "sons de toque" do aparelho — se o
    // usuário desativou sons de toque, ele não toca. (Remova a linha do
    // HapticFeedback se não quiser a vibração.)
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_error != null) {
      return _ErrorView(
        message: _error == 'denied'
            ? l10n.cameraPermissionDenied
            : l10n.cameraError,
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraFill(controller: controller),
          const CardGuideOverlay(),
          _TopBar(
            torchOn: _torchOn,
            onClose: () => Navigator.of(context).pop(),
            onToggleTorch: _toggleTorch,
          ),
          _BottomBar(
            hint: l10n.cameraAlignHint,
            capturing: _capturing,
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
    required this.onClose,
    required this.onToggleTorch,
  });

  final bool torchOn;
  final VoidCallback onClose;
  final VoidCallback onToggleTorch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            IconButton(
              tooltip: l10n.cameraTorch,
              icon: Icon(
                torchOn ? Icons.flash_on : Icons.flash_off,
                color: torchOn
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white,
              ),
              onPressed: onToggleTorch,
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
    required this.capturing,
    required this.onCapture,
  });

  final String hint;
  final bool capturing;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 4,
                      ),
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