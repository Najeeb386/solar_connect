import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.dashboardData.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchDashboard();
                    await controller.fetchPrograms(refresh: true);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(controller),
                        const SizedBox(height: 24),
                        _buildTopPrograms(controller),
                        const SizedBox(height: 24),
                        _buildClaimsSummary(controller),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BrandController controller) {
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
            child: Text('Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Obx(() => controller.isLoading.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2196F3)))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
                  onPressed: () async {
                    await controller.fetchDashboard();
                    await controller.fetchPrograms(refresh: true);
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BrandController controller) {
    return Obx(() {
      final data = controller.dashboardData;

      final totalPrograms = data['programs_count'] ?? data['total_programs'] ?? controller.programs.length;
      final activePrograms = data['active_programs_count'] ?? data['active_programs'] ?? 0;
      final enrolledInstallers = data['enrolled_installers_count'] ?? data['total_enrollments'] ?? 0;
      final announcementsCount = data['announcements_count'] ?? data['total_announcements'] ?? controller.announcements.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.card_giftcard,
                  const Color(0xFF2196F3),
                  'Total Programs',
                  '$totalPrograms',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.play_circle,
                  const Color(0xFF4CAF50),
                  'Active Programs',
                  '$activePrograms',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.people,
                  const Color(0xFFFF9800),
                  'Total Enrollments',
                  '$enrolledInstallers',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.campaign,
                  const Color(0xFF9C27B0),
                  'Announcements',
                  '$announcementsCount',
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(IconData icon, Color color, String title, String value) {
    return Container(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTopPrograms(BrandController controller) {
    return Obx(() {
      final programs = controller.programs;

      return Container(
        padding: const EdgeInsets.all(20),
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
            const Text('Programs by Enrollments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('All your programs ranked by enrollment count', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            if (programs.isEmpty)
              const Text('No programs yet', style: TextStyle(color: Colors.grey))
            else
              ...programs.map((prog) {
                final p = prog as Map;
                final count = p['enrolled_count'] ?? 0;
                final title = p['title']?.toString() ?? 'Untitled';
                final isActive = p['is_active'] == true && p['is_published'] == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProgramRow(title, count, isActive),
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _buildProgramRow(String name, dynamic enrollments, bool isActive) {
    const color = Color(0xFF2196F3);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.card_giftcard, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              Text(isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF4CAF50) : Colors.grey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$enrollments', style: const TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildClaimsSummary(BrandController controller) {
    return Obx(() {
      final stats = controller.claimStats;
      final pending = stats['pending'] ?? 0;
      final approved = stats['approved'] ?? 0;
      final rejected = stats['rejected'] ?? 0;
      final total = (pending is int ? pending : 0) +
          (approved is int ? approved : 0) +
          (rejected is int ? rejected : 0);

      return Container(
        padding: const EdgeInsets.all(20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Claims Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Total: $total', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _claimStatBox('Pending', pending, const Color(0xFFFF9800)),
                const SizedBox(width: 8),
                _claimStatBox('Approved', approved, const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                _claimStatBox('Rejected', rejected, Colors.red),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _claimStatBox(String label, dynamic count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
