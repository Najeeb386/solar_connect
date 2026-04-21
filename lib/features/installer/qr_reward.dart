import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'barcode_scanner_page.dart';
import 'controllers/installer_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kBrand = Color(0xFFFF8F00);
const _kBg = Color(0xFFF5F5F5);

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

  /// key  = "${programId}_${productId}"
  /// value = captured barcode frame bytes (null = not yet captured)
  final Map<String, Uint8List?> _capturedImages = {};

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

    setState(() {
      _capturedImages[_key(programId, productId)] = result.imageBytes;
    });

    Get.snackbar(
      'Barcode Scanned',
      'Barcode captured. Tap "Claim" to submit.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
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
      if (ok) _capturedImages.remove(k); // clear on success
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
              width: 42,
              height: 42,
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
                Text(
                  'Claim Rewards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Scan barcode to submit product claim',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Refresh
          Obx(
            () => _ctrl.claimsLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kBrand,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: _kBrand),
                    onPressed: _ctrl.fetchEnrolledPrograms,
                    tooltip: 'Refresh',
                  ),
          ),
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
          Icon(Icons.info_outline, color: _kBrand, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Select an enrolled program product, capture the barcode/product image, '
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

      if (_ctrl.enrolledPrograms.isEmpty) {
        return _buildEmpty();
      }

      return RefreshIndicator(
        color: _kBrand,
        onRefresh: _ctrl.fetchEnrolledPrograms,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kBrand.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_outlined,
                size: 48,
                color: _kBrand,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Enrolled Programs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to enroll in a brand program first.\n'
              'Go to "Installer Programs" and enroll in a program to start claiming rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _ctrl.fetchEnrolledPrograms,
              icon: const Icon(Icons.refresh, color: _kBrand),
              label: const Text('Refresh', style: TextStyle(color: _kBrand)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kBrand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── program card ─────────────────────────────────────────────────────────────

  Widget _buildProgramCard(Map program) {
    final programId = program['id'] as int? ?? 0;
    final title = program['title']?.toString() ?? 'Program';
    final brandName = program['brand_name']?.toString() ?? '';
    final products = (program['products'] as List?)?.cast<Map>() ?? [];

    final colors = [
      const Color(0xFFFF8F00),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];
    final color = colors[programId % colors.length];
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'P';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Program header ──────────────────────────────────────────────────
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (brandName.isNotEmpty)
                        Text(
                          'by $brandName',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Enrolled',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Products divider ────────────────────────────────────────────────
          if (products.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${products.length} Product${products.length == 1 ? '' : 's'} — tap 📷 to scan barcode',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...products.map(
              (product) => _buildProductRow(programId, product, color),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No products in this program',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
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
    final productId = product['id'] as int? ?? 0;
    final productName = product['name']?.toString() ?? 'Product';
    final series = product['series']?.toString() ?? '';
    final k = _key(programId, productId);
    final captured = _capturedImages[k];
    final isClaiming = _claimingKeys.contains(k);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              // Product icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.solar_power_outlined,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),

              // Product name + series
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (series.isNotEmpty)
                      Text(
                        series,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Scan / re-scan button ─────────────────────────────────────
              GestureDetector(
                onTap: isClaiming
                    ? null
                    : () => _captureImage(programId, productId),
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: captured != null
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : _kBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: captured != null
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                          : _kBrand.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    captured != null ? Icons.camera_alt : Icons.qr_code_scanner,
                    size: 20,
                    color: captured != null ? const Color(0xFF4CAF50) : _kBrand,
                  ),
                ),
              ),

              // ── Claim button ───────────────────────────────────────────────
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isClaiming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              captured != null
                                  ? Icons.send
                                  : Icons.lock_outline,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Claim',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        // ── Captured image preview ─────────────────────────────────────────────
        if (captured != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    captured,
                    width: 64,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Image captured',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap 📷 to retake · Tap "Claim" to submit',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Remove / retake
                GestureDetector(
                  onTap: isClaiming
                      ? null
                      : () => setState(
                          () => _capturedImages.remove(
                            _key(programId, productId),
                          ),
                        ),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),

        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
