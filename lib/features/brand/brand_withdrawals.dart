import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class BrandWithdrawalsPage extends StatefulWidget {
  const BrandWithdrawalsPage({super.key});

  @override
  State<BrandWithdrawalsPage> createState() => _BrandWithdrawalsPageState();
}

class _BrandWithdrawalsPageState extends State<BrandWithdrawalsPage> {
  final BrandController controller = Get.find<BrandController>();

  @override
  void initState() {
    super.initState();
    controller.fetchWithdrawals(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Obx(() => _buildPendingBanner()),
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
          const Expanded(
            child: Text('Withdrawal Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Obx(() => controller.withdrawalsLoading.value
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2196F3)))
            : IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
                onPressed: () => controller.fetchWithdrawals(refresh: true),
              )),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    final count = controller.pendingWithdrawalCount.value;
    if (count == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Text('$count pending request${count > 1 ? 's' : ''} awaiting your payment',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.withdrawalsLoading.value && controller.withdrawals.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
      }
      if (controller.withdrawals.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.money_off, size: 40, color: Color(0xFF2196F3)),
              ),
              const SizedBox(height: 16),
              const Text('No withdrawal requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              const Text('Installers with approved rewards will appear here.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFF2196F3),
        onRefresh: () => controller.fetchWithdrawals(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.withdrawals.length,
          itemBuilder: (ctx, i) =>
            _WithdrawalCard(item: Map<String, dynamic>.from(controller.withdrawals[i])),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _WithdrawalCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _WithdrawalCard({required this.item});

  @override
  State<_WithdrawalCard> createState() => _WithdrawalCardState();
}

class _WithdrawalCardState extends State<_WithdrawalCard> {
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    final isPending  = widget.item['status'] == 'pending';
    final installer  = widget.item['installer_name'] ?? 'Installer';
    final email      = widget.item['installer_email'] ?? '';
    final amount     = double.tryParse(widget.item['amount'].toString()) ?? 0.0;
    final paidAt     = widget.item['paid_at']?.toString() ?? '';
    final createdAt  = _fmtDate(widget.item['created_at']?.toString() ?? '');
    final pm         = widget.item['payment_method'] as Map?;
    final claims     = (widget.item['claims'] as List?)?.cast<Map>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(
          color: isPending ? Colors.orange : Colors.green, width: 4)),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Installer + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      installer.isNotEmpty ? installer[0].toUpperCase() : 'I',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(installer, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Requested $createdAt',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                _statusBadge(isPending),
              ],
            ),

            const SizedBox(height: 12),

            // Amount
            Row(
              children: [
                Text('Rs ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: isPending ? Colors.orange : Colors.green)),
                if (!isPending && paidAt.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('Paid ${_fmtDate(paidAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ],
            ),

            // Payment method
            if (pm != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${(pm['type'] ?? '').toString().toUpperCase()} • ${pm['account_name'] ?? ''} • ${pm['account_no'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
              ),
            ],

            // Claims breakdown
            if (claims.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Approved Rewards',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              ...claims.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF2196F3)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${c['product_name'] ?? ''} — ${c['program_name'] ?? ''}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ),
                    Text('Rs ${c['incentive_amount'] ?? 0}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: Colors.green)),
                  ],
                ),
              )),
            ],

            // Mark as paid button
            if (isPending) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _paying ? null : () => _confirmPay(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _paying
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  label: Text(
                    _paying ? 'Processing...' : 'Mark as Paid — Rs ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPay(BrandController controller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Payment'),
        content: Text(
          'Confirm payment of Rs ${(double.tryParse(widget.item['amount'].toString()) ?? 0).toStringAsFixed(2)} '
          'to ${widget.item['installer_name']}?\n\nThis will deduct the amount from their wallet.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _paying = true);
    await controller.markWithdrawalPaid(widget.item['id'] as int);
    if (mounted) setState(() => _paying = false);
  }

  Widget _statusBadge(bool isPending) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: (isPending ? Colors.orange : Colors.green).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      isPending ? 'PENDING' : 'PAID',
      style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.bold,
        color: isPending ? Colors.orange : Colors.green),
    ),
  );

  static String _fmtDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]}';
    } catch (_) { return raw; }
  }
}
