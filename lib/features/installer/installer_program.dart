import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class InstallerProgramPage extends StatelessWidget {
  const InstallerProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            Expanded(
              child: Obx(() {
                if (controller.programsLoading.value && controller.programs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.fetchPrograms(refresh: true),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatsCard(controller),
                      const SizedBox(height: 20),
                      _buildProgramsList(context, controller),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InstallerController controller) {
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
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Installer Programs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Obx(() => controller.programsLoading.value
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFFF8F00)),
                  onPressed: () => controller.fetchPrograms(refresh: true))),
        ],
      ),
    );
  }

  Widget _buildStatsCard(InstallerController controller) {
    final enrolledCount = controller.programs
        .where((p) => p['is_enrolled'] == true)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Enrollments',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('$enrolledCount Program${enrolledCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final total = controller.programs.length;
            return Text('$total Brand Program${total == 1 ? '' : 's'} Available',
                style: const TextStyle(color: Colors.white70, fontSize: 13));
          }),
        ],
      ),
    );
  }

  Widget _buildProgramsList(BuildContext context, InstallerController controller) {
    if (controller.programs.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No programs available yet.\nBrands will post programs here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.fetchPrograms(refresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00), foregroundColor: Colors.white),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Brand Programs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        const Text('Enroll per product to earn rewards',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        ...controller.programs.map<Widget>(
            (program) => _buildProgramCard(context, program, controller)),
      ],
    );
  }

  Widget _buildProgramCard(
      BuildContext context, dynamic program, InstallerController controller) {
    final title       = program['title']?.toString() ?? 'Program';
    final description = program['description']?.toString() ?? '';
    final brandName   = program['brand']?['name']?.toString() ?? 'Brand';
    final incentive   = program['incentive_amount']?.toString() ?? '0';
    final programId   = program['id'] as int?;
    final products    = (program['products'] as List?) ?? [];
    final allEnrolled = program['all_products_enrolled'] == true;
    final anyEnrolled = program['is_enrolled'] == true;

    final colors = [
      const Color(0xFF2196F3), const Color(0xFFE91E63), const Color(0xFF4CAF50),
      const Color(0xFFFF5722), const Color(0xFF9C27B0), const Color(0xFF00BCD4),
      const Color(0xFFFF9800), const Color(0xFF795548),
    ];
    final colorIdx = brandName.isNotEmpty ? brandName.codeUnitAt(0) % colors.length : 0;
    final color    = colors[colorIdx];
    final initial  = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';

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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(initial,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text('by $brandName',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    if ((double.tryParse(incentive) ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Rs ${double.parse(incentive).toStringAsFixed(0)} per claim',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],

          // ── Products list with per-product enroll buttons ─────────────────────
          if (products.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text('Products — tap Enroll to join per product',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            ...products.map<Widget>((product) {
              final pId        = product['id'] as int?;
              final pName      = product['product_name']?.toString() ?? '';
              final pSeries    = product['product_series']?.toString() ?? '';
              final isEnrolled = product['is_enrolled'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 18, color: color.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (pSeries.isNotEmpty)
                            Text(pSeries,
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    isEnrolled
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    size: 13, color: Color(0xFF4CAF50)),
                                SizedBox(width: 4),
                                Text('Enrolled',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: programId != null && pId != null
                                  ? () => controller.enrollInProgram(
                                        programId,
                                        productId: pId,
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Enroll',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 8),
          Row(
            children: [
              Text('${program['current_enrollments'] ?? 0} enrolled',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              if (anyEnrolled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: allEnrolled
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    allEnrolled ? '✓ All enrolled' : '⚡ Partially enrolled',
                    style: TextStyle(
                      fontSize: 11,
                      color: allEnrolled
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
