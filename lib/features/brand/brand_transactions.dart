import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class BrandTransactionsPage extends StatefulWidget {
  const BrandTransactionsPage({super.key});

  @override
  State<BrandTransactionsPage> createState() => _BrandTransactionsPageState();
}

class _BrandTransactionsPageState extends State<BrandTransactionsPage>
    with SingleTickerProviderStateMixin {
  final BrandController controller = Get.find<BrandController>();
  late TabController _tab;
  final _filters = ['all', 'approved', 'pending', 'rejected'];
  final _labels  = ['All', 'Approved', 'Pending', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _load(_filters[_tab.index]);
    });
    controller.fetchTransactions();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load(String status) =>
    controller.fetchTransactions(status: status == 'all' ? null : status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Obx(() => _buildSummary()),
            _buildTabBar(),
            Expanded(child: _buildList()),
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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF2196F3)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Obx(() => controller.transactionsLoading.value
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2196F3)))
            : IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
                onPressed: () => _load(_filters[_tab.index]),
              )),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final s = controller.transactionSummary;
    if (s.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _stat('Total Paid', 'Rs ${(s['total_paid_out'] ?? 0).toStringAsFixed(0)}',
            const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          _stat('Claims', '${s['total_claims'] ?? 0}', Colors.black87),
          const SizedBox(width: 12),
          _stat('Approved', '${s['approved_claims'] ?? 0}', Colors.green),
          const SizedBox(width: 12),
          _stat('Rejected', '${s['rejected_claims'] ?? 0}', Colors.red),
        ],
      ),
    );
  }

  Widget _stat(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Widget _buildTabBar() => Container(
    color: Colors.white,
    child: TabBar(
      controller: _tab,
      labelColor: const Color(0xFF2196F3),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xFF2196F3),
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      tabs: [for (final l in _labels) Tab(text: l)],
    ),
  );

  Widget _buildList() {
    return Obx(() {
      if (controller.transactionsLoading.value && controller.brandTransactions.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
      }
      final list = controller.brandTransactions;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long, size: 36, color: Color(0xFF2196F3)),
              ),
              const SizedBox(height: 16),
              const Text('No transactions', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, color: Colors.black54)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFF2196F3),
        onRefresh: () => _load(_filters[_tab.index]),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) =>
            _TxCard(tx: Map<String, dynamic>.from(list[i])),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TxCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final status    = tx['status'] ?? 'pending';
    final installer = tx['installer_name'] ?? '—';
    final program   = tx['program_name'] ?? '—';
    final product   = tx['product_name'] ?? '—';
    final amount    = double.tryParse(tx['amount'].toString()) ?? 0.0;
    final released  = tx['payment_released'] == true;
    final date      = _fmtDate(tx['claimed_at']?.toString() ?? '');
    final reason    = tx['rejection_reason']?.toString() ?? '';

    final Color sColor = status == 'approved'
      ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: sColor, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person, color: Color(0xFF2196F3), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(installer, style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(program,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(product,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toUpperCase(),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                        color: sColor)),
                  ),
                  const SizedBox(height: 4),
                  Text('Rs ${amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3))),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 11, color: Colors.grey),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              if (status == 'approved')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (released ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(released ? Icons.check_circle : Icons.pending,
                        size: 10, color: released ? Colors.green : Colors.orange),
                      const SizedBox(width: 3),
                      Text(released ? 'Paid' : 'Pending',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: released ? Colors.green : Colors.orange)),
                    ],
                  ),
                ),
            ],
          ),

          if (status == 'rejected' && reason.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 12, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(child: Text(reason,
                    style: const TextStyle(fontSize: 11, color: Colors.red))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _fmtDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return raw; }
  }
}
