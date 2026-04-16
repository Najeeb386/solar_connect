import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  final List<Map<String, dynamic>> _claims = [
    {
      'installerName': 'Ahmed Khan',
      'installerPhone': '+92 300 1234567',
      'programTitle': 'Summer Installer Incentive 2025',
      'programDetail': 'Rs 500/panel - 25 panels installed',
      'amount': 'Rs 12,500',
      'status': 'Pending',
      'date': '2025-06-15',
    },
    {
      'installerName': 'Muhammad Ali',
      'installerPhone': '+92 301 2345678',
      'programTitle': 'Winter Bonus Program',
      'programDetail': 'Rs 1000 bonus - Winter season',
      'amount': 'Rs 1,000',
      'status': 'Approved',
      'date': '2025-12-20',
    },
    {
      'installerName': 'Saeed Ahmed',
      'installerPhone': '+92 302 3456789',
      'programTitle': 'Battery Installation Reward',
      'programDetail': 'Rs 800/battery - 3 batteries',
      'amount': 'Rs 2,400',
      'status': 'Pending',
      'date': '2025-10-05',
    },
    {
      'installerName': 'Rashid Mehmood',
      'installerPhone': '+92 303 4567890',
      'programTitle': 'Summer Installer Incentive 2025',
      'programDetail': 'Rs 500/panel - 40 panels installed',
      'amount': 'Rs 20,000',
      'status': 'Approved',
      'date': '2025-07-10',
    },
    {
      'installerName': 'Bilal Hussain',
      'installerPhone': '+92 304 5678901',
      'programTitle': 'Spring Promo',
      'programDetail': 'Rs 300/panel - 15 panels installed',
      'amount': 'Rs 4,500',
      'status': 'Rejected',
      'date': '2026-03-25',
    },
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredClaims = _selectedFilter == 'All'
        ? _claims
        : _claims.where((c) => c['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterChips(),
            Expanded(child: _buildClaimsList(filteredClaims)),
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
          const Text(
            'Claims',
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
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
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

  Widget _buildClaimsList(List<Map<String, dynamic>> claims) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        final claim = claims[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    child: Text(
                      claim['installerName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(claim['status']),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                claim['installerPhone'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim['programTitle'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      claim['programDetail'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Claim Amount',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        claim['amount'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    claim['date'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (claim['status'] == 'Pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Rejected',
                            'Claim has been rejected',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Approved',
                            'Claim has been approved',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = const Color(0xFF4CAF50);
        break;
      case 'Rejected':
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
