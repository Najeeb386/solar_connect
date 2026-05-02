import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/storage_image.dart';
import 'controllers/brand_controller.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  final BrandController controller = Get.find<BrandController>();
  String _selectedFilter = 'All';
  bool _isGrid = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    controller.fetchProductClaims();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatsBar(),
            _buildFilterChips(),
            Expanded(child: _buildClaimsList()),
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
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF2196F3)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Claims',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
          Obx(() => controller.claimsLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF2196F3)))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
                  onPressed: () => controller.fetchProductClaims(),
                )),
          GestureDetector(
            onTap: () => setState(() {
              _isGrid = !_isGrid;
              _currentPage = 0;
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isGrid ? Icons.view_list : Icons.grid_view,
                color: const Color(0xFF2196F3),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final photoUrl =
                (controller.userProfile['user']?['profile_photo'] ?? '')
                    .toString();
            final name = (controller.userProfile['profile']?['company_name'] ??
                    controller.dashboardData['user']?['name'] ??
                    'B')
                .toString();
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';
            return GestureDetector(
              onTap: () => controller.changePage(7),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Text(initial,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2196F3)))))
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3)))),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Obx(() {
      final stats = controller.claimStats;
      final pending = stats['pending'] ?? 0;
      final approved = stats['approved'] ?? 0;
      final rejected = stats['rejected'] ?? 0;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            _statChip('Pending', pending, const Color(0xFFFF9800)),
            const SizedBox(width: 8),
            _statChip('Approved', approved, const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            _statChip('Rejected', rejected, Colors.red),
          ],
        ),
      );
    });
  }

  Widget _statChip(String label, dynamic count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                    _currentPage = 0;
                  });
                  if (filter == 'All') {
                    controller.fetchProductClaims();
                  } else {
                    controller.fetchProductClaims(status: filter.toLowerCase());
                  }
                },
                selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF2196F3),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildClaimsList() {
    return Obx(() {
      if (controller.claimsLoading.value && controller.productClaims.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2196F3)));
      }
      if (controller.productClaims.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 'All'
                    ? 'No claims yet'
                    : 'No $_selectedFilter claims',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }

      final all = controller.productClaims.cast<Map>().toList();
      final totalPages = (all.length / _pageSize).ceil();
      final start = _currentPage * _pageSize;
      final end = (start + _pageSize).clamp(0, all.length);
      final paged = all.sublist(start, end);
      final showPagination = all.length > _pageSize;

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final status = _selectedFilter == 'All'
                    ? null
                    : _selectedFilter.toLowerCase();
                await controller.fetchProductClaims(status: status);
              },
              child: _isGrid
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: paged.length,
                      itemBuilder: (ctx, i) => _buildClaimCardGrid(paged[i]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: paged.length,
                      itemBuilder: (ctx, i) =>
                          _buildClaimCard(ctx, paged[i]),
                    ),
            ),
          ),
          if (showPagination)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        foregroundColor: const Color(0xFF2196F3)),
                  ),
                  Text('Page ${_currentPage + 1} of $totalPages',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
                  TextButton.icon(
                    onPressed: _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('Next'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3)),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildClaimCardGrid(Map claim) {
    final installer = claim['installer'] as Map? ?? {};
    final installerUser = installer['user'] as Map? ?? {};
    final installerName = installerUser['name']?.toString() ??
        claim['installer_name']?.toString() ??
        'Unknown';
    final program = claim['program'] as Map? ?? {};
    final programTitle =
        program['title']?.toString() ?? claim['program_title']?.toString() ?? '';
    final product = claim['product'] as Map? ?? {};
    final productName =
        product['product_name']?.toString() ?? claim['product_name']?.toString() ?? '';
    final amount = claim['incentive_amount']?.toString() ??
        claim['amount']?.toString() ??
        '0';
    final status = (claim['status']?.toString() ?? 'pending');
    final statusDisplay = status[0].toUpperCase() + status.substring(1);

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = const Color(0xFFFF9800);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(statusDisplay,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor)),
            ),
          ),
          const SizedBox(height: 8),
          Text(installerName,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(programTitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (productName.isNotEmpty)
            Text(productName,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('Rs $amount',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3))),
          if (status == 'pending') ...[
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRejectDialog(
                      Get.context!, claim['id'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                        child: Text('Reject',
                            style:
                                TextStyle(fontSize: 10, color: Colors.red))),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.approveProductClaim(claim['id'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                        child: Text('Approve',
                            style: TextStyle(
                                fontSize: 10, color: Colors.white))),
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, Map claim) {
    // Extract data safely
    final installer = claim['installer'] as Map? ?? {};
    final installerUser = installer['user'] as Map? ?? {};
    final installerName = installerUser['name']?.toString() ?? claim['installer_name']?.toString() ?? 'Unknown Installer';
    final installerPhone = installerUser['phone']?.toString() ?? claim['installer_phone']?.toString() ?? '';

    final program = claim['program'] as Map? ?? {};
    final programTitle = program['title']?.toString() ?? claim['program_title']?.toString() ?? 'Unknown Program';

    final product = claim['product'] as Map? ?? {};
    final productName = product['product_name']?.toString() ?? claim['product_name']?.toString() ?? '';

    final amount = claim['incentive_amount']?.toString() ?? claim['amount']?.toString() ?? '0';
    final status = (claim['status']?.toString() ?? 'pending');
    final statusDisplay = status[0].toUpperCase() + status.substring(1);
    final date = claim['created_at']?.toString().split('T').first ?? '';

    // Barcode image URL — API returns 'barcode_image_url'
    final barcodeImageUrl = claim['barcode_image_url']?.toString() ??
        claim['qr_code_url']?.toString() ??
        claim['barcode_image']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Installer name + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(installerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _buildStatusBadge(statusDisplay),
            ],
          ),
          if (installerPhone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(installerPhone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Program & product info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(programTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (productName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(productName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
                if (claim['notes'] != null && (claim['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(claim['notes'].toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Amount + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Claim Amount', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    'Rs $amount',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                  ),
                ],
              ),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),

          // Barcode image — loaded via CORS-safe StorageImage proxy
          if (barcodeImageUrl != null && barcodeImageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: StorageImage(
                url: barcodeImageUrl,
                width: double.infinity,
                height: 140,
                fit: BoxFit.contain,
                errorWidget: Container(
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Image unavailable', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Reject reason (if rejected)
          if (status == 'rejected' && claim['rejection_reason'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${claim['rejection_reason']}',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Approve / Reject buttons (only for pending)
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, claim['id'] as int),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.approveProductClaim(claim['id'] as int),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int claimId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.rejectProductClaim(
                claimId: claimId,
                rejectionReason: reasonController.text.trim().isEmpty ? 'Rejected by brand' : reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = const Color(0xFF4CAF50);
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = const Color(0xFFFF9800);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
