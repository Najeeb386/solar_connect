import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class ClaimHistoryPage extends StatefulWidget {
  const ClaimHistoryPage({super.key});

  @override
  State<ClaimHistoryPage> createState() => _ClaimHistoryPageState();
}

class _ClaimHistoryPageState extends State<ClaimHistoryPage>
    with SingleTickerProviderStateMixin {
  final InstallerController controller = Get.find<InstallerController>();
  String _selectedFilter = 'all';
  late TabController _tabController;
  final ScrollController _scrollCtrl = ScrollController();

  final _filters = const ['all', 'pending', 'approved', 'rejected'];
  final _labels  = const ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applyFilter(_filters[_tabController.index]);
      }
    });
    _scrollCtrl.addListener(_onScroll);
    controller.fetchClaimHistory(refresh: true);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      controller.fetchClaimHistory(loadMore: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyFilter(String filter) async {
    setState(() => _selectedFilter = filter);
    await controller.fetchClaimHistory(
      status: filter == 'all' ? null : filter,
      refresh: true,
    );
  }

  // ── Summary — use server total + current list counts ─────────────────────
  Map<String, int> get _counts {
    final all = controller.claimHistory;
    return {
      'all':      controller.claimHistoryTotal.value,
      'pending':  all.where((c) => c['status'] == 'pending').length,
      'approved': all.where((c) => c['status'] == 'approved').length,
      'rejected': all.where((c) => c['status'] == 'rejected').length,
    };
  }

  double get _totalEarned => controller.claimHistory
      .where((c) => c['status'] == 'approved')
      .fold(0.0, (sum, c) => sum + (double.tryParse(c['amount'].toString()) ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Obx(() => _buildSummaryRow()),
            _buildTabBar(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Claim History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Obx(() => controller.claimHistoryLoading.value
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)))
            : IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFFF8F00)),
                onPressed: () => _applyFilter(_selectedFilter),
              )),
        ],
      ),
    );
  }

  // ── Stats strip ───────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    if (controller.claimHistoryLoading.value && controller.claimHistory.isEmpty) {
      return const SizedBox(height: 80,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8F00))));
    }
    final c = _counts;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _statChip('Total',    c['all'].toString(),      const Color(0xFF607D8B)),
          const SizedBox(width: 8),
          _statChip('Pending',  c['pending'].toString(),  const Color(0xFFFFA000)),
          const SizedBox(width: 8),
          _statChip('Approved', c['approved'].toString(), const Color(0xFF43A047)),
          const SizedBox(width: 8),
          _statChip('Rejected', c['rejected'].toString(), const Color(0xFFE53935)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Earned', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Rs ${_totalEarned.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                    color: Color(0xFF43A047))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFF8F00),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFFFF8F00),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: [
          for (final label in _labels) Tab(text: label),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      if (controller.claimHistoryLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8F00)));
      }

      final list = controller.claimHistory;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long,
                  size: 40, color: Color(0xFFFF8F00)),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 'all'
                  ? 'No claims yet'
                  : 'No ${_selectedFilter} claims',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                    color: Colors.black54)),
              const SizedBox(height: 8),
              const Text('Submit product claims to see them here.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        );
      }

      final hasMore = controller.claimHistoryPage.value <
                      controller.claimHistoryLastPage.value;

      return RefreshIndicator(
        color: const Color(0xFFFF8F00),
        onRefresh: () => _applyFilter(_selectedFilter),
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: list.length + 1, // +1 for footer
          itemBuilder: (context, i) {
            // Footer
            if (i == list.length) {
              return _buildPaginationFooter(hasMore);
            }
            return _ClaimCard(claim: Map<String, dynamic>.from(list[i]));
          },
        ),
      );
    });
  }

  Widget _buildPaginationFooter(bool hasMore) {
    return Obx(() {
      final loading = controller.claimHistoryLoadingMore.value;
      final page    = controller.claimHistoryPage.value;
      final last    = controller.claimHistoryLastPage.value;
      final total   = controller.claimHistoryTotal.value;

      if (!hasMore && !loading) {
        if (total == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'All $total claim${total == 1 ? '' : 's'} loaded',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFFFF8F00)),
              ),
            ),
          // Page indicator pills
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prev
                _pageBtn(
                  icon: Icons.chevron_left,
                  enabled: page > 1 && !loading,
                  onTap: () => _loadPage(page - 1),
                ),
                const SizedBox(width: 8),
                // Page info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Page $page of $last',
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8F00)),
                  ),
                ),
                const SizedBox(width: 8),
                // Next
                _pageBtn(
                  icon: Icons.chevron_right,
                  enabled: hasMore && !loading,
                  onTap: () => _loadPage(page + 1),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _loadPage(int targetPage) async {
    _scrollCtrl.animateTo(0,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    // Set page to targetPage-1 so loadMore increments to targetPage
    controller.claimHistoryPage.value     = targetPage - 1;
    controller.claimHistoryLastPage.value =
        controller.claimHistoryLastPage.value; // keep last page
    await controller.fetchClaimHistory(loadMore: true);
  }

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled
            ? const Color(0xFFFF8F00).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
          size: 20,
          color: enabled ? const Color(0xFFFF8F00) : Colors.grey),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Claim Card
// ─────────────────────────────────────────────────────────────────────────────

class _ClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final status   = claim['status'] ?? 'pending';
    final program  = claim['program_name'] ?? '—';
    final product  = claim['product_name'] ?? '—';
    final amount   = double.tryParse(claim['amount'].toString()) ?? 0.0;
    final date     = _formatDate(claim['claimed_at']?.toString() ?? '');
    final reviewed = _formatDate(claim['reviewed_at']?.toString() ?? '');
    final reason   = claim['rejection_reason']?.toString() ?? '';
    final released = claim['payment_released'] == true;

    final statusConfig = _statusConfig(status);

    return GestureDetector(
      onTap: () => _showDetail(context, program, product, amount, status,
          date, reviewed, reason, released),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: statusConfig['color'] as Color, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: program + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.card_giftcard,
                      color: Color(0xFFFF8F00), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(program,
                          style: const TextStyle(fontSize: 15,
                            fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(product,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusBadge(status, statusConfig),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),

              // Bottom row: amount + date + payment indicator
              Row(
                children: [
                  Text('Rs ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: statusConfig['color'] as Color)),
                  const Spacer(),
                  // Payment released pill (only show for approved)
                  if (status == 'approved')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: released
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            released ? Icons.check_circle : Icons.pending,
                            size: 12,
                            color: released ? Colors.green : Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            released ? 'Paid' : 'Awaiting',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold,
                              color: released ? Colors.green : Colors.orange)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(date,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),

              // Rejection reason
              if (status == 'rejected' && reason.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(reason,
                          style: const TextStyle(fontSize: 12, color: Colors.red)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Map statusConfig) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (statusConfig['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusConfig['icon'] as IconData,
            size: 11, color: statusConfig['color'] as Color),
          const SizedBox(width: 4),
          Text(status.toUpperCase(),
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold,
              color: statusConfig['color'] as Color)),
        ],
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    String program, String product, double amount, String status,
    String date, String reviewed, String reason, bool released,
  ) {
    final statusConfig = _statusConfig(status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: (statusConfig['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusConfig['icon'] as IconData,
                    color: statusConfig['color'] as Color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Claim Details',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: statusConfig['color'] as Color)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _detailRow(Icons.card_giftcard, 'Program', program),
            _detailRow(Icons.inventory_2, 'Product', product),
            _detailRow(Icons.currency_rupee, 'Incentive Amount',
              'Rs ${amount.toStringAsFixed(2)}'),
            _detailRow(Icons.calendar_today, 'Claimed On', date),
            if (reviewed.isNotEmpty)
              _detailRow(Icons.rate_review, 'Reviewed On', reviewed),
            if (status == 'approved')
              _detailRow(
                released ? Icons.check_circle : Icons.pending,
                'Payment',
                released ? 'Released ✓' : 'Awaiting payment from brand',
                valueColor: released ? Colors.green : Colors.orange,
              ),
            if (status == 'rejected' && reason.isNotEmpty)
              _detailRow(Icons.cancel, 'Rejection Reason', reason,
                valueColor: Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Expanded(
            child: Text(value,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  static Map _statusConfig(String status) {
    switch (status) {
      case 'approved':
        return {'color': const Color(0xFF43A047), 'icon': Icons.check_circle};
      case 'rejected':
        return {'color': const Color(0xFFE53935), 'icon': Icons.cancel};
      default:
        return {'color': const Color(0xFFFFA000), 'icon': Icons.access_time};
    }
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
