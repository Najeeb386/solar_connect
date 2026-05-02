import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result model
// ─────────────────────────────────────────────────────────────────────────────

/// Returned from [BarcodeScannerPage].
/// [value]      = decoded barcode / QR string.
/// [imageBytes] = filled by caller (qr_reward.dart generates QR from value).
class ScanResult {
  final String value;
  final Uint8List imageBytes;
  const ScanResult({required this.value, required this.imageBytes});
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanner page
// ─────────────────────────────────────────────────────────────────────────────

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late final MobileScannerController _ctrl;

  bool   _done             = false;
  String? _lastValue;          // last auto-detected value
  bool   _holding          = false; // countdown active
  int    _holdCountdown    = 2;
  Timer? _holdTimer;

  double _zoomLevel        = 0.0;

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // ── auto-detect callback ───────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final val = capture.barcodes.firstOrNull?.rawValue;
    if (val == null || val.isEmpty) return;

    // New / changed detection → restart countdown
    if (!_holding || val != _lastValue) {
      _lastValue = val;
      _holdTimer?.cancel();
      setState(() {
        _holding       = true;
        _holdCountdown = 2;
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_holdCountdown > 1) {
        setState(() => _holdCountdown--);
      } else {
        t.cancel();
        _finish(_lastValue!);
      }
    });
  }

  // ── finish ─────────────────────────────────────────────────────────────────

  Future<void> _finish(String value) async {
    if (_done) return;
    _done = true;
    _holdTimer?.cancel();
    await _ctrl.stop();
    if (!mounted) return;
    // imageBytes left empty — qr_reward.dart generates QR from value
    Navigator.of(context).pop(
      ScanResult(value: value, imageBytes: Uint8List(0)),
    );
  }

  // ── manual capture ─────────────────────────────────────────────────────────

  void _manualCapture() {
    if (_done) return;

    if (_lastValue != null) {
      // Already have a detected value — confirm it
      _holdTimer?.cancel();
      _finish(_lastValue!);
    } else {
      // Nothing detected yet — prompt user to move closer
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No code detected yet. Move closer and hold steady.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(controller: _ctrl, onDetect: _onDetect),

          // Scan frame overlay
          const _ScanOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _iconBtn(Icons.close, () => Navigator.of(context).pop()),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: _ctrl,
                    builder: (_, state, _) {
                      final on = state.torchState == TorchState.on;
                      return _iconBtn(
                        on ? Icons.flash_on : Icons.flash_off,
                        _ctrl.toggleTorch,
                        color: on ? Colors.amber : Colors.white,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Hold-still overlay ─────────────────────────────────────────────
          if (_holding)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: Colors.greenAccent, size: 34),
                        const SizedBox(height: 8),
                        Text(
                          _holdCountdown > 0
                              ? 'Hold still...  $_holdCountdown'
                              : 'Got it ✓',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Keep barcode / QR steady',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Bottom controls ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom slider
                  Row(
                    children: [
                      const Icon(Icons.zoom_out,
                          color: Colors.white60, size: 20),
                      Expanded(
                        child: Slider(
                          value: _zoomLevel,
                          min: 0, max: 1,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                          onChanged: (v) {
                            setState(() => _zoomLevel = v);
                            _ctrl.setZoomScale(v);
                          },
                        ),
                      ),
                      const Icon(Icons.zoom_in,
                          color: Colors.white60, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Status hint
                  Text(
                    _holding
                        ? 'Barcode detected — holding steady...'
                        : 'Auto-scanning — or tap button below',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Manual capture button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _done ? null : _manualCapture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _lastValue != null
                            ? Colors.greenAccent
                            : Colors.white,
                        foregroundColor: Colors.black87,
                        disabledBackgroundColor:
                            Colors.white.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        _lastValue != null
                            ? Icons.check_circle
                            : Icons.camera_alt,
                        size: 20,
                      ),
                      label: Text(
                        _lastValue != null
                            ? 'Confirm & Use Detected Code'
                            : 'Scan / Try Again',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
          {Color color = Colors.white}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan frame overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    const boxSize = 260.0;
    final screen = MediaQuery.of(context).size;
    final left   = (screen.width  - boxSize) / 2;
    final top    = (screen.height - boxSize) / 2 - 60;

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.52)),
        ),
        Positioned(
          left: left, top: top, width: boxSize, height: boxSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white38, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        _corner(left, top, true, true),
        _corner(left + boxSize - 24, top, false, true),
        _corner(left, top + boxSize - 24, true, false),
        _corner(left + boxSize - 24, top + boxSize - 24, false, false),
      ],
    );
  }

  Widget _corner(double l, double t, bool flipH, bool flipV) => Positioned(
    left: l, top: t, width: 24, height: 24,
    child: Transform.scale(
      scaleX: flipH ? 1 : -1,
      scaleY: flipV ? 1 : -1,
      child: CustomPaint(painter: _CornerPainter()),
    ),
  );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }
  @override
  bool shouldRepaint(_) => false;
}
