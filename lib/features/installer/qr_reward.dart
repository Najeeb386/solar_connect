import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'barcode_scanner_page.dart';
import 'controllers/installer_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kBrand = Color(0xFFFF8F00);
const _kBg    = Color(0xFFF5F5F5);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Try to parse a scanned value as a SolarPartner product QR.
/// Returns map with keys: pid, pname, series, bid, bname — or null.
Map<String, dynamic>? _parseProductQR(String raw) {
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (map['app'] == 'solar' && map['pid'] != null) return map;
  } catch (_) {}
  return null;
}

/// Generate a clean QR image (PNG bytes) from [data].
/// This image is what gets saved to the DB — not the raw camera frame.
Future<Uint8List> _generateQrBytes(String data) async {
  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: ui.Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: ui.Color(0xFF000000),
    ),
  );
  final image = await painter.toImage(300);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class QRRewardPage extends StatefulWidget {
  const QRRewardPage({super.key});

  @override
  State<QRRewardPage> createState() => _QRRewardPageState();
}

class _QRRewardPageState extends State<QRRewardPage> {
  InstallerController get _ctrl => Get.find<InstallerController>();

  /// key = "${programId}_${productId}"
  final Map<String, Uint8List?> _capturedImages   = {};
  final Map<String, Map<String, dynamic>> _scannedInfo = {}; // QR decoded data

  /// tracks which product is currently being claimed (showing spinner)
  final Set<String> _claimingKeys = {};

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (_ctrl.enrolledPrograms.isEmpty) _ctrl.fetchEnrolledPrograms();
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  String _key(int programId, int productId) => '${programId}_$productId';

  Uint8List? _imageFor(int programId, int productId) =>
      _capturedImages[_key(programId, productId)];

  // ── capture barcode image ────────────────────────────────────────────────────

  Future<void> _captureImage(int programId, int productId) async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (result == null || !mounted) return;

    // Parse decoded QR/barcode data
    final info = _parseProductQR(result.value);

    // Generate clean QR image from decoded value → this is saved to DB
    Uint8List qrBytes;
    try {
      qrBytes = await _generateQrBytes(result.value);
    } catch (_) {
      qrBytes = result.imageBytes; // fallback to camera frame if QR gen fails
    }

    final k = _key(programId, productId);
    setState(() {
      _capturedImages[k] = qrBytes;
      if (info != null) { _scannedInfo[k] = info; } else { _scannedInfo.remove(k); }
    });

    if (info != null) {
      final qrPid = int.tryParse(info['pid'].toString()) ?? -1;
      final matches = qrPid == productId;
      Get.snackbar(
        matches ? '✓ Product Verified' : '⚠ Different Product Scanned',
        matches
          ? '${info['pname'] ?? 'Product'} detected. Tap "Claim" to submit.'
          : 'QR is for "${info['pname'] ?? '?'}" — verify before claiming.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: (matches ? Colors.green : Colors.orange)
            .withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: Icon(matches ? Icons.verified : Icons.warning_amber,
            color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Code Captured',
        'Data read. Tap "Claim" to submit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }
  }

  // ── quick standalone scan ────────────────────────────────────────────────────

  Future<void> _quickScan() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (result == null || !mounted) return;

    // Generate QR image from decoded data
    Uint8List qrBytes;
    try {
      qrBytes = await _generateQrBytes(result.value);
    } catch (_) {
      qrBytes = result.imageBytes;
    }
    final resultWithQr = ScanResult(value: result.value, imageBytes: qrBytes);

    final info = _parseProductQR(result.value);
    if (info != null) {
      _showScannedProductSheet(resultWithQr, info);
    } else {
      _showRawScanSheet(result.value, qrBytes);
    }
  }

  // ── submit claim ─────────────────────────────────────────────────────────────

  Future<void> _submitClaim(int programId, int productId) async {
    final bytes = _imageFor(programId, productId);
    if (bytes == null) return;

    final k = _key(programId, productId);
    setState(() => _claimingKeys.add(k));

    final ok = await _ctrl.submitProductClaim(
      programId: programId,
      productId: productId,
      imageBytes: bytes,
    );

    setState(() {
      _claimingKeys.remove(k);
      if (ok) {
        _capturedImages.remove(k);
        _scannedInfo.remove(k);
      }
    });
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildInfoBanner(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      // Quick Scan FAB hidden — reserved for future use
      floatingActionButton: null,
    );
  }

  // ── header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _kBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: _kBrand),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Claim Rewards',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: Colors.black87)),
                Text('Scan barcode to submit product claim',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Obx(() => _ctrl.claimsLoading.value
            ? const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kBrand))
            : IconButton(
                icon: const Icon(Icons.refresh, color: _kBrand),
                onPressed: _ctrl.fetchEnrolledPrograms,
                tooltip: 'Refresh',
              )),
        ],
      ),
    );
  }

  // ── info banner ──────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBrand.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.qr_code_scanner, color: _kBrand, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scan the brand\'s product QR code to auto-verify product info, '
              'then tap "Claim" to submit for review.',
              style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (_ctrl.enrolledPrograms.isEmpty && _ctrl.claimsLoading.value) {
        return const Center(child: CircularProgressIndicator(color: _kBrand));
      }
      if (_ctrl.enrolledPrograms.isEmpty) return _buildEmpty();

      return RefreshIndicator(
        color: _kBrand,
        onRefresh: _ctrl.fetchEnrolledPrograms,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // 80 for FAB
          itemCount: _ctrl.enrolledPrograms.length,
          itemBuilder: (ctx, i) {
            final program = _ctrl.enrolledPrograms[i] as Map;
            return _buildProgramCard(program);
          },
        ),
      );
    });
  }

  // ── empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: _kBrand.withValues(alpha: 0.08),
                shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard_outlined,
                size: 48, color: _kBrand),
            ),
            const SizedBox(height: 20),
            const Text('No Enrolled Programs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: Colors.black87)),
            const SizedBox(height: 8),
            const Text(
              'You need to enroll in a brand program first.\n'
              'Go to "Installer Programs" and enroll to start claiming rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _ctrl.fetchEnrolledPrograms,
              icon: const Icon(Icons.refresh, color: _kBrand),
              label: const Text('Refresh', style: TextStyle(color: _kBrand)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kBrand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }

  // ── program card ─────────────────────────────────────────────────────────────

  Widget _buildProgramCard(Map program) {
    final programId = program['id'] as int? ?? 0;
    final title     = program['title']?.toString() ?? 'Program';
    final brandName = program['brand_name']?.toString() ?? '';
    final products  = (program['products'] as List?)?.cast<Map>() ?? [];

    const colors = [
      Color(0xFFFF8F00), Color(0xFF2196F3), Color(0xFF4CAF50),
      Color(0xFF9C27B0), Color(0xFFE91E63), Color(0xFF00BCD4),
    ];
    final color   = colors[programId % colors.length];
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'P';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(initial,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                        color: color)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                      if (brandName.isNotEmpty)
                        Text('by $brandName',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                  ),
                  child: const Text('Enrolled',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Products
          if (products.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${products.length} Product${products.length == 1 ? '' : 's'}'
                    ' — tap 📷 to scan barcode / QR',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...products.map((p) => _buildProductRow(programId, p, color)),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text('No products in this program',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── product row ──────────────────────────────────────────────────────────────

  Widget _buildProductRow(int programId, Map product, Color accentColor) {
    final productId   = product['id'] as int? ?? 0;
    final productName = product['name']?.toString() ?? 'Product';
    final series      = product['series']?.toString() ?? '';
    final k           = _key(programId, productId);
    final captured    = _capturedImages[k];
    final info        = _scannedInfo[k];
    final isClaiming  = _claimingKeys.contains(k);

    // Verify if QR matches this product
    final qrMatch = info == null
      ? null
      : int.tryParse(info['pid'].toString()) == productId;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.solar_power_outlined, size: 20, color: accentColor),
              ),
              const SizedBox(width: 10),

              // Name + series
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                    if (series.isNotEmpty)
                      Text(series, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),

              // Scan button
              GestureDetector(
                onTap: isClaiming ? null : () => _captureImage(programId, productId),
                child: Container(
                  width: 38, height: 38,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: captured != null
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : _kBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: captured != null
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                        : _kBrand.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    captured != null ? Icons.camera_alt : Icons.qr_code_scanner,
                    size: 20,
                    color: captured != null ? const Color(0xFF4CAF50) : _kBrand),
                ),
              ),

              // Claim button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: (captured != null && !isClaiming)
                    ? () => _submitClaim(programId, productId)
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrand,
                    disabledBackgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isClaiming
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(captured != null ? Icons.send : Icons.lock_outline, size: 14),
                          const SizedBox(width: 4),
                          const Text('Claim',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),

        // ── Captured image + QR info preview ─────────────────────────────────
        if (captured != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: qrMatch == false
                ? Colors.orange.withValues(alpha: 0.06)
                : const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: qrMatch == false
                  ? Colors.orange.withValues(alpha: 0.4)
                  : const Color(0xFF4CAF50).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(captured, width: 64, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status row
                      Row(
                        children: [
                          Icon(
                            info != null
                              ? (qrMatch == true ? Icons.verified : Icons.warning_amber)
                              : Icons.check_circle,
                            size: 13,
                            color: info != null
                              ? (qrMatch == true ? Colors.green : Colors.orange)
                              : const Color(0xFF4CAF50)),
                          const SizedBox(width: 4),
                          Text(
                            info != null
                              ? (qrMatch == true ? 'QR Verified' : 'QR Mismatch')
                              : 'Image captured',
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: info != null
                                ? (qrMatch == true ? Colors.green : Colors.orange)
                                : const Color(0xFF2E7D32))),
                        ],
                      ),

                      // Decoded QR data
                      if (info != null) ...[
                        const SizedBox(height: 4),
                        _qrInfoRow('Product', info['pname']?.toString() ?? ''),
                        if ((info['series']?.toString() ?? '').isNotEmpty)
                          _qrInfoRow('Series', info['series'].toString()),
                        _qrInfoRow('Brand', info['bname']?.toString() ?? ''),
                      ] else ...[
                        const SizedBox(height: 2),
                        const Text('Tap 📷 to retake · Tap "Claim" to submit',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                // Remove
                GestureDetector(
                  onTap: isClaiming
                    ? null
                    : () => setState(() {
                        _capturedImages.remove(k);
                        _scannedInfo.remove(k);
                      }),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _qrInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Expanded(
          child: Text(value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: Colors.black87),
            overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );

  // ── quick scan sheets ────────────────────────────────────────────────────────

  void _showScannedProductSheet(ScanResult result, Map<String, dynamic> info) {
    // Find if product is in enrolled programs
    Map? matchedProgram;
    Map? matchedProduct;
    final qrPid = int.tryParse(info['pid'].toString()) ?? -1;

    for (final prog in _ctrl.enrolledPrograms) {
      final products = (prog['products'] as List?)?.cast<Map>() ?? [];
      for (final prod in products) {
        if ((prod['id'] as int? ?? 0) == qrPid) {
          matchedProgram = prog;
          matchedProduct = prod;
          break;
        }
      }
      if (matchedProgram != null) break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductScanSheet(
        result: result,
        info: info,
        matchedProgram: matchedProgram,
        matchedProduct: matchedProduct,
        onClaim: matchedProgram != null && matchedProduct != null
          ? () async {
              final programId = (matchedProgram!['id'] as int? ?? 0);
              final productId = (matchedProduct!['id'] as int? ?? 0);
              final k = _key(programId, productId);
              setState(() {
                _capturedImages[k] = result.imageBytes;
                _scannedInfo[k]    = info;
                _claimingKeys.add(k);
              });
              Navigator.of(context).pop();
              final ok = await _ctrl.submitProductClaim(
                programId: programId,
                productId: productId,
                imageBytes: result.imageBytes,
              );
              setState(() {
                _claimingKeys.remove(k);
                if (ok) {
                  _capturedImages.remove(k);
                  _scannedInfo.remove(k);
                }
              });
            }
          : null,
      ),
    );
  }

  void _showRawScanSheet(String rawValue, Uint8List imageBytes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.qr_code, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Scanned Result',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close), padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
            ]),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(imageBytes, height: 120, width: double.infinity,
                fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
              child: SelectableText(rawValue,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 15),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'This is not a SolarPartner product QR. '
                  'Scan a QR code generated by a brand from their product page.',
                  style: TextStyle(fontSize: 11, color: Colors.orange))),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Scan Result Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ProductScanSheet extends StatefulWidget {
  final ScanResult result;
  final Map<String, dynamic> info;
  final Map? matchedProgram;
  final Map? matchedProduct;
  final Future<void> Function()? onClaim;

  const _ProductScanSheet({
    required this.result,
    required this.info,
    required this.matchedProgram,
    required this.matchedProduct,
    required this.onClaim,
  });

  @override
  State<_ProductScanSheet> createState() => _ProductScanSheetState();
}

class _ProductScanSheetState extends State<_ProductScanSheet> {
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final matched    = widget.matchedProgram != null;
    final pname      = widget.info['pname']?.toString() ?? 'Unknown Product';
    final series     = widget.info['series']?.toString() ?? '';
    final bname      = widget.info['bname']?.toString() ?? '';
    final progTitle  = widget.matchedProgram?['title']?.toString() ?? '';
    final reward     = widget.matchedProduct?['reward']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Title
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (matched ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                shape: BoxShape.circle),
              child: Icon(
                matched ? Icons.verified : Icons.warning_amber,
                color: matched ? Colors.green : Colors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                matched ? 'Product Detected!' : 'Product Not in Programs',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close), padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
          ]),
          const SizedBox(height: 16),

          // Scanned image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(widget.result.imageBytes,
              height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 14),

          // Product info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(Icons.inventory_2_outlined, 'Product', pname),
                if (series.isNotEmpty) _row(Icons.label_outline, 'Series', series),
                _row(Icons.business, 'Brand', bname),
                if (matched) ...[
                  _row(Icons.card_giftcard, 'Program', progTitle),
                  if (reward.isNotEmpty)
                    _row(Icons.attach_money, 'Reward', 'Rs $reward'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (!matched) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'This product is not part of your enrolled programs. '
                    'Enroll in the brand\'s program to claim rewards for this product.',
                    style: TextStyle(fontSize: 12, color: Colors.orange))),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Claim button
          if (matched)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _claiming ? null : () async {
                  setState(() => _claiming = true);
                  await widget.onClaim?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBrand,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                icon: _claiming
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send, color: Colors.white, size: 18),
                label: Text(
                  _claiming ? 'Submitting...' : 'Submit Claim',
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
