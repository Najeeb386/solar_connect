import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final InstallerController controller = Get.find<InstallerController>();

  static const _orange = Color(0xFFFF8F00);

  @override
  void initState() {
    super.initState();
    if (controller.walletData.isEmpty) controller.fetchWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.walletLoading.value && controller.walletData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _orange),
            );
          }
          return RefreshIndicator(
            color: _orange,
            onRefresh: () => controller.fetchWallet(),
            child: ListView(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildBalanceCard(context),
                const SizedBox(height: 16),
                _buildPendingWithdrawals(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Transaction History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                _buildTransactionList(),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
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
                color: _orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: _orange),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Obx(() => controller.walletLoading.value
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _orange))
            : IconButton(
                icon: const Icon(Icons.refresh, color: _orange),
                onPressed: () => controller.fetchWallet(),
              )),
        ],
      ),
    );
  }

  // ─── Balance Card ─────────────────────────────────────────────────────────────
  Widget _buildBalanceCard(BuildContext context) {
    final balance = double.tryParse(
      controller.walletData['balance']?.toString() ?? '0') ?? 0.0;
    final hasPending = controller.pendingWithdrawals.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _orange.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Balance',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              'Rs ${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                  size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                const Text('Earned from approved claims',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: hasPending ? null : () => _showWithdrawModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white54,
                  foregroundColor: _orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(
                  hasPending ? Icons.hourglass_top : Icons.arrow_upward,
                  size: 18,
                  color: hasPending ? Colors.grey : _orange,
                ),
                label: Text(
                  hasPending ? 'Withdrawal Pending...' : 'Withdraw Funds',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasPending ? Colors.grey : _orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pending Withdrawals ─────────────────────────────────────────────────────
  // API structure: each item = { id, total_amount, status, created_at, brands: [{brand_name, amount, status}] }
  Widget _buildPendingWithdrawals() {
    return Obx(() {
      if (controller.pendingWithdrawals.isEmpty) return const SizedBox.shrink();

      final list = controller.pendingWithdrawals;
      // total = sum of all items' total_amount
      final totalAmt = list.fold<double>(0.0, (sum, item) {
        final m = item as Map;
        return sum + (double.tryParse(m['total_amount']?.toString() ?? '0') ?? 0.0);
      });

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Pending Withdrawal',
                        style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 14, color: Colors.orange)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Rs ${totalAmt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 13, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Waiting for brands to confirm payment. Balance deducted after each brand marks as paid.',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              // Per-request → per-brand rows
              ...list.map((item) {
                final req    = item as Map;
                final reqAmt = double.tryParse(req['total_amount']?.toString() ?? '0') ?? 0.0;
                final reqStatus = req['status']?.toString() ?? 'pending';
                final brands = (req['brands'] as List?) ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Request header row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, size: 12, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Request • Rs ${reqAmt.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey,
                              fontWeight: FontWeight.w500)),
                          const Spacer(),
                          _statusPill(reqStatus),
                        ],
                      ),
                    ),
                    // Brand breakdown
                    ...brands.map((b) {
                      final brand   = b['brand_name']?.toString() ?? 'Brand';
                      final amt     = double.tryParse(b['amount']?.toString() ?? '0') ?? 0.0;
                      final bStatus = b['status']?.toString() ?? 'pending';
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          children: [
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  brand.isNotEmpty ? brand[0].toUpperCase() : 'B',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13,
                                    color: Color(0xFF2196F3)))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(brand,
                                style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w500))),
                            Text('Rs ${amt.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12,
                                fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            _statusPill(bStatus),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    });
  }

  Widget _statusPill(String status) {
    final isPaid = status == 'paid';
    final isPartial = status == 'partially_paid';
    final color = isPaid ? Colors.green : isPartial ? Colors.blue : Colors.orange;
    final label = isPaid ? 'Paid' : isPartial ? 'Partial' : 'Pending';
    final icon  = isPaid ? Icons.check_circle : isPartial ? Icons.timelapse : Icons.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final credited = double.tryParse(
      controller.walletData['total_credited']?.toString() ?? '0') ?? 0.0;
    final debited = double.tryParse(
      controller.walletData['total_debited']?.toString() ?? '0') ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard('Total Earned', 'Rs ${credited.toStringAsFixed(2)}',
            Icons.arrow_downward, Colors.green),
          const SizedBox(width: 12),
          _statCard('Total Withdrawn', 'Rs ${debited.toStringAsFixed(2)}',
            Icons.arrow_upward, Colors.red),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  // ─── Transaction List ─────────────────────────────────────────────────────────
  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
          child: const Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No transactions yet',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
            ],
          ),
        );
      }
      return Column(
        children: controller.transactions.map((item) {
          final tx = item as Map;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _TxItem(tx: tx),
          );
        }).toList(),
      );
    });
  }

  // ─── Withdraw Modal ───────────────────────────────────────────────────────────
  void _showWithdrawModal(BuildContext context) {
    final amountCtrl = TextEditingController();
    int? selectedMethodId;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final balance = double.tryParse(
            controller.walletData['balance']?.toString() ?? '0') ?? 0.0;
          final methods = controller.paymentMethods.toList();

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Withdraw Funds',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: _orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your withdrawal is sent to each brand for payment confirmation. '
                            'Balance is only deducted after a brand marks your request as paid.',
                            style: TextStyle(
                              fontSize: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Balance display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Balance',
                        style: TextStyle(color: Colors.grey)),
                      Text('Rs ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: _orange)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment method
                  if (methods.isNotEmpty) ...[
                    const Text('Payment Method',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text('Select payment method'),
                          value: selectedMethodId,
                          onChanged: (val) =>
                            setModalState(() => selectedMethodId = val),
                          items: methods.map<DropdownMenuItem<int>>((m) {
                            final map = m as Map;
                            final id = int.tryParse(map['id'].toString()) ?? 0;
                            final label = map['type_display'] ?? map['type'] ?? '';
                            final acct = map['account_number_masked'] ??
                              map['account_number'] ?? '';
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text('$label — $acct',
                                overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: _orange, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please add a payment method before withdrawing.',
                              style: TextStyle(color: Color(0xFFE65100), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Amount field
                  const Text('Amount (min Rs 100)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: 'Rs ',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: submitting ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (methods.isEmpty || submitting)
                            ? null
                            : () async {
                                final amt = double.tryParse(amountCtrl.text.trim());
                                if (amt == null || amt < 100) {
                                  Get.snackbar('Error', 'Minimum Rs 100',
                                    snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                if (selectedMethodId == null) {
                                  Get.snackbar('Error', 'Select a payment method',
                                    snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                if (amt > balance) {
                                  Get.snackbar('Error', 'Amount exceeds balance',
                                    snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                setModalState(() => submitting = true);
                                final ok = await controller.withdraw(
                                  selectedMethodId!, amt);
                                if (ok && ctx.mounted) {
                                  Navigator.pop(ctx);
                                } else {
                                  setModalState(() => submitting = false);
                                }
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                          child: submitting
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                            : const Text('Confirm Withdraw',
                                style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Transaction Item Widget ─────────────────────────────────────────────────
class _TxItem extends StatelessWidget {
  final Map tx;
  const _TxItem({required this.tx});

  static const _green = Color(0xFF4CAF50);
  static const _red = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final type = tx['type']?.toString().toLowerCase() ?? '';
    final isCredit = type == 'credit';
    final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
    final description = tx['description']?.toString() ?? 'Transaction';
    final balAfter = tx['balance_after'];
    // API returns 'date' field (not 'created_at')
    final rawDate = tx['date']?.toString() ?? tx['created_at']?.toString() ?? '';
    final dateParts = _parseDate(rawDate);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(
          color: isCredit ? _green : _red, width: 3)),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: (isCredit ? _green : _red).withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18, color: isCredit ? _green : _red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${dateParts[0]}  ${dateParts[1]}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isCredit
                  ? '+Rs ${amount.toStringAsFixed(2)}'
                  : '-Rs ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold,
                  color: isCredit ? _green : _red),
              ),
              if (balAfter != null)
                Text('Bal: Rs ${double.tryParse(balAfter.toString())?.toStringAsFixed(2) ?? balAfter}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  static List<String> _parseDate(String raw) {
    if (raw.isEmpty) return ['', ''];
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final date = '${dt.day} ${m[dt.month - 1]} ${dt.year}';
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final time = '${h.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')} ${dt.hour >= 12 ? "PM" : "AM"}';
      return [date, time];
    } catch (_) { return [raw, '']; }
  }
}
