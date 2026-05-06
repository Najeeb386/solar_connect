import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'barcode_scanner_page.dart';
import 'controllers/installer_controller.dart';

class ProductClaimsPage extends StatefulWidget {
  const ProductClaimsPage({super.key});

  @override
  State<ProductClaimsPage> createState() => _ProductClaimsPageState();
}

class _ProductClaimsPageState extends State<ProductClaimsPage> {
  final InstallerController controller = Get.find<InstallerController>();
  String _selectedFilter = 'all';
  bool _isGrid = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    String? status = _selectedFilter != 'all' ? _selectedFilter : null;
    await controller.fetchProductClaims(status: status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterBar(),
            Expanded(child: _buildClaimsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SubmitProductClaimPage()),
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Submit Claim',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'My Claims',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _isGrid = !_isGrid;
              _currentPage = 0;
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isGrid ? Icons.view_list : Icons.grid_view,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedFilter = value;
          _currentPage = 0;
        });
        await _loadClaims();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildClaimsList() {
    return Obx(() {
      if (controller.claimsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredClaims = _selectedFilter == 'all'
          ? controller.productClaims.cast<Map>().toList()
          : controller.productClaims
                .cast<Map>()
                .where((claim) => claim['status'] == _selectedFilter)
                .toList();

      if (filteredClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.document_scanner, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No claims yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      final totalPages = (filteredClaims.length / _pageSize).ceil();
      final start = _currentPage * _pageSize;
      final end = (start + _pageSize).clamp(0, filteredClaims.length);
      final paged = filteredClaims.sublist(start, end);
      final showPagination = filteredClaims.length > _pageSize;

      return Column(
        children: [
          Expanded(
            child: _isGrid
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: paged.length,
                    itemBuilder: (context, i) =>
                        _buildClaimCardGrid(paged[i]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: paged.length,
                    itemBuilder: (context, i) {
                      final claim = paged[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildClaimCard(
                          title: claim['product_name'] ?? 'Unknown Product',
                          program:
                              claim['program_title'] ?? 'Unknown Program',
                          status: claim['status'] ?? 'unknown',
                          date: claim['created_at'] ?? 'Unknown date',
                          rejection: claim['rejection_reason'],
                        ),
                      );
                    },
                  ),
          ),
          if (showPagination)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('Prev'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                  Text(
                    'Page ${_currentPage + 1} of $totalPages',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  TextButton.icon(
                    onPressed: _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('Next'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildClaimCardGrid(Map claim) {
    final status = (claim['status'] ?? 'unknown').toString();
    final statusColor = status == 'pending'
        ? Colors.amber
        : status == 'approved'
            ? Colors.green
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            claim['product_name'] ?? 'Unknown Product',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            claim['program_title'] ?? 'Unknown Program',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            claim['created_at'] ?? '',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (claim['rejection_reason'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    claim['rejection_reason'].toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.red),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimCard({
    required String title,
    required String program,
    required String status,
    required String date,
    String? rejection,
  }) {
    final statusColor = status == 'pending'
        ? Colors.amber
        : status == 'approved'
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () {
        // Navigate to claim details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program,
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
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (rejection != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rejection,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitProductClaimPage extends StatefulWidget {
  const SubmitProductClaimPage({super.key});

  @override
  State<SubmitProductClaimPage> createState() => _SubmitProductClaimPageState();
}

class _SubmitProductClaimPageState extends State<SubmitProductClaimPage> {
  final InstallerController controller = Get.find<InstallerController>();

  int? _selectedProgramId;
  int? _selectedProductId;
  Uint8List? _barcodeImageBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    await controller.fetchEnrolledPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    _buildProgramSelector(),
                    const SizedBox(height: 20),
                    _buildProductSelector(),
                    const SizedBox(height: 20),
                    _buildBarcodeCapture(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Submit Product Claim',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Program', _selectedProgramId != null),
        const SizedBox(width: 8),
        _buildStep(2, 'Product', _selectedProductId != null),
        const SizedBox(width: 8),
        _buildStep(3, 'Barcode', _barcodeImageBytes != null),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool completed) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF3B82F6) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      step.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Program *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Obx(() {
            final programs = controller.enrolledPrograms;
            if (programs.isEmpty) {
              return const Text(
                'No programs available',
                style: TextStyle(color: Colors.grey),
              );
            }
            return DropdownButton<int>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedProgramId,
              hint: const Text('Choose a program...'),
              items: _buildProgramItems(programs),
              onChanged: (value) {
                setState(() {
                  _selectedProgramId = value;
                  _selectedProductId = null;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _buildProgramItems(List programs) {
    if (programs.isEmpty) return [];
    return programs.asMap().entries.map((entry) {
      final program = entry.value is Map ? entry.value as Map : {};
      return DropdownMenuItem<int>(
        value: program['id'] as int? ?? entry.key,
        child: Text(program['title']?.toString() ?? 'Program ${entry.key + 1}'),
      );
    }).toList();
  }

  Widget _buildProductSelector() {
    final isEnabled = _selectedProgramId != null;
    final program = isEnabled ? _findProgram(_selectedProgramId!) : null;
    final products = program?['products'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Product *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<int>(
            isExpanded: true,
            underline: const SizedBox(),
            value: _selectedProductId,
            hint: Text(
              isEnabled ? 'Choose a product...' : 'Select a program first',
            ),
            items: isEnabled && products.isNotEmpty
                ? _buildProductItems(products)
                : [],
            onChanged: isEnabled
                ? (value) => setState(() => _selectedProductId = value)
                : null,
          ),
        ),
      ],
    );
  }

  Map? _findProgram(int id) {
    final programs = controller.enrolledPrograms;
    for (final p in programs) {
      if (p is Map && p['id'] == id) return p as Map;
    }
    return null;
  }

  List<DropdownMenuItem<int>> _buildProductItems(List products) {
    if (products.isEmpty) return [];
    return products.asMap().entries.map((entry) {
      final product = entry.value is Map ? entry.value as Map : {};
      return DropdownMenuItem<int>(
        value: product['id'] as int? ?? entry.key,
        child: Text(product['name']?.toString() ?? 'Product ${entry.key + 1}'),
      );
    }).toList();
  }

  Widget _buildBarcodeCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Capture Barcode Image *',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _barcodeImageBytes == null ? _captureBarcode : null,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _barcodeImageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Color(0xFF3B82F6),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to scan barcode / QR code',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Camera opens automatically — no gallery',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _barcodeImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _barcodeImageBytes = null),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, size: 16, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Make sure the barcode is clearly visible and well-lit for accurate scanning',
                  style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _captureBarcode() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (result != null && mounted) {
      setState(() => _barcodeImageBytes = result.imageBytes);
    }
  }

  Widget _buildSubmitButton() {
    final isEnabled =
        _selectedProgramId != null &&
        _selectedProductId != null &&
        _barcodeImageBytes != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled && !_isSubmitting ? _submitClaim : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit Claim',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _submitClaim() async {
    setState(() => _isSubmitting = true);
    final success = await controller.submitProductClaim(
      programId: _selectedProgramId!,
      productId: _selectedProductId!,
      imageBytes: _barcodeImageBytes!,
    );
    setState(() => _isSubmitting = false);
    if (success) {
      Get.back();
    }
  }
}
