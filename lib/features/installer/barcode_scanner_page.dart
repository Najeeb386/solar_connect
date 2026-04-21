import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Result returned from [BarcodeScannerPage].
class ScanResult {
  final String value;
  final Uint8List imageBytes;
  const ScanResult({required this.value, required this.imageBytes});
}

/// Full-screen barcode / QR scanner.
/// Validates that a real barcode or QR code is present before accepting.
/// Returns [ScanResult] with the decoded value + a JPEG frame for upload.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late final MobileScannerController _ctrl;
  bool _detected = false;
  String? _detectedValue;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      returnImage: true, // capture frame on detection
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_detected) return; // already handled
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || (barcode.rawValue?.isEmpty ?? true)) return;

    final imageBytes = capture.image;
    if (imageBytes == null) return;

    _detected = true;
    await _ctrl.stop();

    if (!mounted) return;
    // Pop back with result
    Navigator.of(context).pop(
      ScanResult(value: barcode.rawValue!, imageBytes: imageBytes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Overlay: dimmed corners + clear scan box
          _ScanOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                  const Spacer(),
                  // Torch toggle
                  ValueListenableBuilder(
                    valueListenable: _ctrl,
                    builder: (_, state, __) {
                      final torchOn = state.torchState == TorchState.on;
                      return GestureDetector(
                        onTap: () => _ctrl.toggleTorch(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            torchOn ? Icons.flash_on : Icons.flash_off,
                            color: torchOn ? Colors.amber : Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction label
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Point at barcode or QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hold steady — scanning automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dimmed overlay with a transparent scan window in the centre.
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const boxSize = 260.0;
    final screen = MediaQuery.of(context).size;
    final left   = (screen.width  - boxSize) / 2;
    final top    = (screen.height - boxSize) / 2 - 40;

    return Stack(
      children: [
        // Dim everything
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
        ),
        // Clear window
        Positioned(
          left: left, top: top, width: boxSize, height: boxSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Corner accents
        _corner(left, top, true, true),
        _corner(left + boxSize - 24, top, false, true),
        _corner(left, top + boxSize - 24, true, false),
        _corner(left + boxSize - 24, top + boxSize - 24, false, false),
      ],
    );
  }

  Widget _corner(double l, double t, bool flipH, bool flipV) {
    return Positioned(
      left: l, top: t, width: 24, height: 24,
      child: Transform.scale(
        scaleX: flipH ? 1 : -1,
        scaleY: flipV ? 1 : -1,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
