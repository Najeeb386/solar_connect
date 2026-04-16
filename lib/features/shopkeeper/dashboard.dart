import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jobs.dart';
import 'shopkeeper_profile.dart';
import 'notifications.dart';
import 'installers.dart';
import 'controllers/shopkeeper_controller.dart';

final List<Widget> _pages = [
  const ShopkeeperDashboardHome(),
  const JobsPage(),
  const ShopkeepersPage(),
  const NotificationsPage(),
  const ShopkeeperProfilePage(),
];

class ShopkeeperDashboard extends StatelessWidget {
  const ShopkeeperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopkeeperController controller = Get.find<ShopkeeperController>();

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

  Widget _buildDrawer(BuildContext context, ShopkeeperController controller) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo Shop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'shop@solar.test',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
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
              () =>
                  _buildDrawerItem(1, Icons.work, 'Jobs', controller, context),
            ),
            Obx(
              () => _buildDrawerItem(
                2,
                Icons.search,
                'Find Installers',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                3,
                Icons.notifications,
                'Notifications',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                4,
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
                onTap: () => Get.offAllNamed('/login'),
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
    ShopkeeperController controller,
    BuildContext context,
  ) {
    final isSelected = controller.currentIndex.value == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF9C27B0) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
      onTap: () {
        controller.changePage(index);
        Navigator.pop(context);
      },
    );
  }
}

class ShopkeeperDashboardHome extends StatelessWidget {
  const ShopkeeperDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildRecentJobs(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildJobsByStatus(),
              const SizedBox(height: 24),
            ],
          ),
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
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF9C27B0)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopkeeper Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Solar Connect',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatCard(
            Icons.work,
            const Color(0xFF9C27B0),
            'Total Jobs',
            '0',
          ),
          _buildStatCard(
            Icons.play_circle,
            const Color(0xFF2196F3),
            'Active Jobs',
            '0',
          ),
          _buildStatCard(
            Icons.check_circle,
            const Color(0xFF4CAF50),
            'Completed Jobs',
            '0',
          ),
          _buildStatCard(
            Icons.attach_money,
            const Color(0xFFFF9800),
            'Total Spent',
            'PKR 0',
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
  ) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    return Container(
      width: (screenWidth - 52) / 2,
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
        ],
      ),
    );
  }

  Widget _buildRecentJobs() {
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
                  'Recent Jobs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(color: Color(0xFF9C27B0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.work_off, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No jobs posted yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Post your first job',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  Icons.add,
                  'Post a New Job',
                  const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  Icons.search,
                  'Browse Installers',
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  Icons.list,
                  'View All Jobs',
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {},
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

  Widget _buildJobsByStatus() {
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
            const Text(
              'Jobs by Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem('Open', '0', const Color(0xFFFF9800)),
                ),
                Expanded(
                  child: _buildStatusItem(
                    'In Progress',
                    '0',
                    const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    'Completed',
                    '0',
                    const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(child: _buildStatusItem('Cancelled', '0', Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
