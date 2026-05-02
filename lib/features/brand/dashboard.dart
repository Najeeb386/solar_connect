import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'programs.dart';
import 'products.dart';
import 'claims.dart';
import 'announcements.dart';
import 'manuals.dart';
import 'analytics.dart';
import 'brand_profile.dart';
import 'brand_withdrawals.dart';
import 'brand_transactions.dart';
import 'controllers/brand_controller.dart';

final List<Widget> _pages = [
  const BrandDashboardHome(),      // 0
  const ProgramsPage(),            // 1
  const ProductsScreen(),          // 2
  const ClaimsPage(),              // 3
  const AnnouncementsPage(),       // 4
  const ManualsPage(),             // 5
  const AnalyticsPage(),           // 6
  const BrandProfilePage(),        // 7
  const BrandWithdrawalsPage(),    // 8
  const BrandTransactionsPage(),   // 9
];

class BrandDashboard extends StatelessWidget {
  const BrandDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (controller.currentIndex.value != 0) {
            controller.changePage(0);
          }
        }
      },
      child: Obx(
        () => Scaffold(
          key: GlobalKey<ScaffoldState>(),
          backgroundColor: const Color(0xFFF5F5F5),
          drawer: _buildDrawer(context, controller),
          body: _pages[controller.currentIndex.value],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, BrandController controller) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Obx(() {
                final brandName = controller.userProfile['profile']?['company_name']
                    ?? controller.dashboardData['brand_name']
                    ?? controller.dashboardData['user']?['name']
                    ?? 'Brand';
                final email = controller.dashboardData['user']?['email'] ?? '';
                final photoUrl = (controller.userProfile['user']?['profile_photo'] ?? '').toString();
                final initial = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.changePage(7);
                        Navigator.pop(Get.context!);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(initial,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2196F3))),
                                  ),
                                )
                              : Center(
                                  child: Text(initial,
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2196F3))),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      brandName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 10),
            Obx(
              () => _buildDrawerItem(
                0,
                Icons.dashboard,
                'Dashboard',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                1,
                Icons.card_giftcard,
                'Programs',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                2,
                Icons.shopping_bag,
                'Products',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                3,
                Icons.receipt_long,
                'Claims',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                4,
                Icons.campaign,
                'Announcements',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                5,
                Icons.folder,
                'Manuals',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                6,
                Icons.analytics,
                'Analytics',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                7,
                Icons.person,
                'My Profile',
                controller,
                context,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFF44336)),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFF44336)),
                ),
                onTap: () {
                  Get.offAllNamed('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    int index,
    IconData icon,
    String title,
    BrandController controller,
    BuildContext context,
  ) {
    final isSelected = controller.currentIndex.value == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
      onTap: () {
        controller.changePage(index);
        Navigator.pop(context);
      },
    );
  }
}

class BrandDashboardHome extends StatelessWidget {
  const BrandDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDashboard,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, controller),
                  const SizedBox(height: 16),
                  _buildStatsCards(controller),
                  const SizedBox(height: 20),
                  _buildQuickLinks(context, controller),
                  const SizedBox(height: 20),
                  _buildRecentPrograms(controller),
                  const SizedBox(height: 20),
                  _buildRecentAnnouncements(controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BrandController controller) {
    return Obx(() {
      final userData = controller.dashboardData['user'];
      final companyName = controller.userProfile['profile']?['company_name']
          ?? userData?['name'] ?? 'Brand';
      final email = userData?['email'] ?? '';
      final photoUrl = (controller.userProfile['user']?['profile_photo'] ?? '').toString();
      final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'B';

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $companyName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => controller.changePage(7),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(initial,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2196F3))),
                          ),
                        )
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3))),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsCards(BrandController controller) {
    final totalPrograms = controller.dashboardData['programs_count'] ?? 0;
    final activePrograms = controller.dashboardData['active_programs_count'] ?? 0;
    final enrolledInstallers = controller.dashboardData['enrolled_installers_count'] ?? 0;
    final completedEnrollments = controller.dashboardData['completed_enrollments'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.card_giftcard,
              const Color(0xFF2196F3),
              'Total Programs',
              '$totalPrograms / $activePrograms',
              'Total / Active',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.people,
              const Color(0xFFFF9800),
              'Enrollments',
              '$enrolledInstallers / $completedEnrollments',
              'Total / Completed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color color,
    String title,
    String value,
    String subtitle,
  ) {
    return Container(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context, BrandController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickLink(
                  Icons.add,
                  'Create\nProgram',
                  const Color(0xFF2196F3),
                  onTap: () => Get.to(() => const ProgramFormPage()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickLink(
                  Icons.campaign,
                  'New\nAnnouncement',
                  const Color(0xFFFF9800),
                  onTap: () => controller.changePage(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickLink(
                  Icons.upload_file,
                  'Upload\nManual',
                  const Color(0xFF9C27B0),
                  onTap: () => controller.changePage(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink(IconData icon, String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPrograms(BrandController controller) {
    final programs = controller.dashboardData['programs'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                const Text(
                  'Recent Programs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.find<BrandController>().changePage(1),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (programs.isEmpty)
              _buildProgramItem('No programs yet', '', 'N/A')
            else
              ...programs
                  .take(3)
                  .map(
                    (p) => _buildProgramItem(
                      p['title'] ?? 'Program',
                      p['incentive_amount'] != null ? 'Rs ${p['incentive_amount']}' : '',
                      (p['is_active'] == true && p['is_published'] == true) ? 'active' : 'inactive',
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramItem(String title, String reward, String status) {
    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? const Color(0xFF4CAF50) : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Color(0xFF2196F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  reward,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 11, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnnouncements(BrandController controller) {
    final announcements =
        controller.announcements as List? ?? [];
    final latest = announcements.isNotEmpty ? announcements.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                const Text(
                  'Recent Announcements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.find<BrandController>().changePage(4),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              latest?['title'] ?? 'No announcements yet',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              latest?['body'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
