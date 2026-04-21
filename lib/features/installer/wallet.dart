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

  @override
  void initState() {
    super.initState();
    if (controller.walletData.isEmpty) {
      controller.fetchWallet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.walletLoading.value && controller.walletData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
            );
          }
          return RefreshIndicator(
            color: const Color(0xFFFF8F00),
            onRefresh: () => controller.fetchWallet(),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildBalanceCard(context),
                const SizedBox(height: 20),
                _buildTransactionHistory(),
              ],
            ),
          );
        }),
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
                color: const Color(0xFFFF8F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Wallet',
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

  Widget _buildBalanceCard(BuildContext context) {
    final balance = controller.walletData['balance'] ?? 0.0;
    final balanceText = 'Rs ${double.tryParse(balance.toString())?.toStringAsFixed(2) ?? '0.00'}';

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
              color: const Color(0xFFFF8F00).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              balanceText,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Available for withdrawal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showWithdrawModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF8F00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.transactions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No transactions yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = controller.transactions[index] as Map;
                      final type = tx['type'] ?? '';
                      final isCredit = type.toString().toLowerCase() == 'credit';
                      final amount = tx['amount'] ?? 0;
                      final amountFormatted = isCredit
                          ? '+${double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount}'
                          : '-${double.tryParse(amount.toString())?.toStringAsFixed(2) ?? amount}';
                      final description = tx['description'] ?? 'Transaction';
                      final createdAt = tx['created_at'] ?? '';
                      final dateParts = _parseDateTime(createdAt.toString());

                      return _buildTransactionItem(
                        date: dateParts[0],
                        time: dateParts[1],
                        description: description.toString(),
                        type: isCredit ? 'Credit' : 'Debit',
                        amount: amountFormatted,
                        balanceAfter: tx['balance_after'] != null
                            ? 'Rs ${double.tryParse(tx['balance_after'].toString())?.toStringAsFixed(2) ?? tx['balance_after']}'
                            : '',
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseDateTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return ['N/A', ''];
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final date =
          '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final time =
          '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
      return [date, time];
    } catch (_) {
      return [dateTimeStr, ''];
    }
  }

  Widget _buildTransactionItem({
    required String date,
    required String time,
    required String description,
    required String type,
    required String amount,
    required String balanceAfter,
  }) {
    final isCredit = type == 'Credit';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isCredit
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCredit
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF44336),
                ),
              ),
              if (balanceAfter.isNotEmpty)
                Text(
                  balanceAfter,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawModal(BuildContext context) {
    final amountController = TextEditingController();
    int? selectedMethodId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final balance = controller.walletData['balance'] ?? 0.0;
          final balanceText =
              'Rs ${double.tryParse(balance.toString())?.toStringAsFixed(2) ?? '0.00'}';
          final methods = controller.paymentMethods.toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
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
                  const Text(
                    'Withdraw Funds',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balanceText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8F00),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (methods.isNotEmpty) ...[
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
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
                            final label = map['type_display'] ??
                                map['type'] ??
                                'Account';
                            final masked = map['account_number_masked'] ??
                                map['account_number'] ??
                                '';
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                '$label — $masked',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Amount (min Rs 500)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '500',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (methods.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFFFF8F00), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please link and verify your bank account before withdrawing.',
                              style: TextStyle(
                                  color: Color(0xFFE65100), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: methods.isEmpty
                              ? null
                              : () async {
                                  final amountVal = double.tryParse(
                                      amountController.text.trim());
                                  if (amountVal == null || amountVal < 500) {
                                    Get.snackbar(
                                      'Error',
                                      'Minimum withdrawal amount is Rs 500',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  if (selectedMethodId == null) {
                                    Get.snackbar(
                                      'Error',
                                      'Please select a payment method',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  Navigator.pop(ctx);
                                  await controller.withdraw(
                                      selectedMethodId!, amountVal);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8F00),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm Withdraw',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
