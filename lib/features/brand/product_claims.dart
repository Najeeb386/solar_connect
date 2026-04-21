import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class BrandProductClaimsPage extends StatefulWidget {
  const BrandProductClaimsPage({super.key});

  @override
  State<BrandProductClaimsPage> createState() => _BrandProductClaimsPageState();
}

class _BrandProductClaimsPageState extends State<BrandProductClaimsPage> {
  final BrandController controller = Get.find<BrandController>();
  String _selectedFilter = 'all';

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
            _buildStatsBar(),
            Expanded(
              child: _buildClaimsList(),
            ),
          ],
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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Product Claims', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
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
        setState(() => _selectedFilter = value);
        await _loadClaims();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.grey[300]!,
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

  Widget _buildStatsBar() {
    return Obx(() {
      final stats = controller.claimStats;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Pending', (stats['pending'] ?? 0).toString(), Colors.amber),
            _buildStatItem('Approved', (stats['approved'] ?? 0).toString(), Colors.green),
            _buildStatItem('Rejected', (stats['rejected'] ?? 0).toString(), Colors.red),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildClaimsList() {
    return Obx(() {
      if (controller.claimsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredClaims = _selectedFilter == 'all'
          ? controller.productClaims
          : controller.productClaims
              .where((claim) => claim['status'] == _selectedFilter)
              .toList();

      if (filteredClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fact_check, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No claims found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredClaims.length,
        itemBuilder: (context, index) {
          final claim = filteredClaims[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildClaimCard(
              claimId: claim['id'] ?? 0,
              installerName: claim['installer_name'] ?? 'Unknown Installer',
              productTitle: claim['product_name'] ?? 'Unknown Product',
              program: claim['program_title'] ?? 'Unknown Program',
              status: claim['status'] ?? 'unknown',
              date: claim['created_at'] ?? 'Unknown date',
              barcodeUrl: claim['barcode_image_url'] ?? 'https://via.placeholder.com/150',
              paymentReleased: claim['payment_released'] ?? false,
              rejectionReason: claim['rejection_reason'],
            ),
          );
        },
      );
    });
  }

  Widget _buildClaimCard({
    required int claimId,
    required String installerName,
    required String productTitle,
    required String program,
    required String status,
    required String date,
    required String barcodeUrl,
    bool paymentReleased = false,
    String? rejectionReason,
  }) {
    final statusColor = status == 'pending'
        ? Colors.amber
        : status == 'approved'
            ? Colors.green
            : Colors.red;

    return GestureDetector(
      onTap: () => _showClaimDetails(
        installerName: installerName,
        productTitle: productTitle,
        program: program,
        status: status,
        barcodeUrl: barcodeUrl,
        rejectionReason: rejectionReason,
      ),
      child: Container(
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
            // Top section with installer info and status badge
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          installerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ),
            // Barcode image section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    barcodeUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Bottom section with date and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (paymentReleased)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Payment Released',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (rejectionReason != null) ...[
                    const SizedBox(height: 8),
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
                              rejectionReason,
                              style: const TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Action buttons only for pending claims
                  if (status == 'pending') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveClaim(claimId, installerName, productTitle),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rejectClaim(claimId, installerName, productTitle),
                            icon: const Icon(Icons.cloud_circle),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimDetails({
    required String installerName,
    required String productTitle,
    required String program,
    required String status,
    required String barcodeUrl,
    String? rejectionReason,
  }) {
    Get.defaultDialog(
      title: 'Claim Details',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _detailRow('Installer', installerName),
            const SizedBox(height: 12),
            _detailRow('Product', productTitle),
            const SizedBox(height: 12),
            _detailRow('Program', program),
            const SizedBox(height: 12),
            _detailRow('Status', status),
            const SizedBox(height: 16),
            const Text(
              'Barcode Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  barcodeUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (rejectionReason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Reason',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rejectionReason,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Close'),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _approveClaim(int claimId, String installerName, String productTitle) async {
    Get.back();
    final success = await controller.approveProductClaim(claimId);
    if (success) {
      setState(() {});
    }
  }

  void _rejectClaim(int claimId, String installerName, String productTitle) {
    Get.back();
    _showRejectionReasonDialog(claimId, installerName, productTitle);
  }

  void _showRejectionReasonDialog(int claimId, String installerName, String productTitle) {
    final reasonController = TextEditingController();
    Get.defaultDialog(
      title: 'Reject Claim',
      content: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Please provide a reason for rejection:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter rejection reason...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (reasonController.text.isEmpty) {
            Get.snackbar(
              'Error',
              'Please enter a rejection reason',
              backgroundColor: Colors.red.withValues(alpha: 0.8),
              colorText: Colors.white,
            );
            return;
          }
          Get.back();
          final success = await controller.rejectProductClaim(
            claimId: claimId,
            rejectionReason: reasonController.text,
          );
          if (success) {
            setState(() {});
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Reject'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
