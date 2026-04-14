import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  final List<Map<String, dynamic>> _programs = [
    {
      'title': 'Summer Installer Incentive 2025',
      'description': 'Flat discount on all installations',
      'reward': 'Rs 500/panel',
      'status': 'Active',
      'enrollments': 45,
      'startDate': '2025-06-01',
      'endDate': '2025-08-31',
    },
    {
      'title': 'Winter Bonus Program',
      'description': 'Bonus for winter installations',
      'reward': 'Rs 1000 bonus',
      'status': 'Active',
      'enrollments': 28,
      'startDate': '2025-12-01',
      'endDate': '2026-02-28',
    },
    {
      'title': 'New Year Special Offer',
      'description': 'Special offers for new year',
      'reward': '20% off',
      'status': 'Draft',
      'enrollments': 0,
      'startDate': '',
      'endDate': '',
    },
    {
      'title': 'Battery Installation Reward',
      'description': 'Extra reward for battery setups',
      'reward': 'Rs 800/battery',
      'status': 'Active',
      'enrollments': 15,
      'startDate': '2025-09-01',
      'endDate': '2025-11-30',
    },
  ];

  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showCreateForm)
              Expanded(child: _buildCreateForm())
            else
              Expanded(child: _buildProgramsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
        backgroundColor: const Color(0xFF2196F3),
        icon: Icon(
          _showCreateForm ? Icons.list : Icons.add,
          color: Colors.white,
        ),
        label: Text(
          _showCreateForm ? 'View Programs' : 'Create Program',
          style: const TextStyle(color: Colors.white),
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
            'Programs',
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

  Widget _buildCreateForm() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final maxEnrollmentsController = TextEditingController();
    final eligibilityController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool publishImmediately = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Installer Program',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in the details below to create a new program.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Program Title *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                'e.g. Summer Installer Incentive 2025',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: _inputDecoration(
                'Describe the program, its goals and benefits...',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Incentive Amount (PKR) *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 5000'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        readOnly: true,
                        decoration: _inputDecoration('mm/dd/yyyy'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        readOnly: true,
                        decoration: _inputDecoration('mm/dd/yyyy'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Max Enrollments (optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: maxEnrollmentsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Leave blank for unlimited'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Eligibility Criteria (optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: eligibilityController,
              maxLines: 2,
              decoration: _inputDecoration(
                'List requirements or conditions...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: const Color(0xFF2196F3),
                ),
                const Text('Publish immediately (uncheck to save as draft)'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showCreateForm = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Success',
                        'Program created successfully!',
                        backgroundColor: const Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                      setState(() => _showCreateForm = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Create Program',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildProgramsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _programs.length,
      itemBuilder: (context, index) {
        final program = _programs[index];
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
                      program['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: program['status'] == 'Active'
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      program['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: program['status'] == 'Active'
                            ? const Color(0xFF4CAF50)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                program['description'],
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 16,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    program['reward'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${program['enrollments']} enrolled',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
