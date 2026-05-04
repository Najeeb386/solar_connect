import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
            Obx(() {
              final profileUser = controller.userProfile['user'];
              final dashUser = controller.dashboardData['user'];
              final storage = GetStorage();
              final storedUser = storage.read('user');
              final userName = profileUser?['name'] ??
                  dashUser?['name'] ??
                  storedUser?['name'] ??
                  'Shopkeeper';
              final userEmail = profileUser?['email'] ??
                  dashUser?['email'] ??
                  storedUser?['email'] ??
                  '';
              final shopName =
                  controller.userProfile['profile']?['shop_name'] ?? userName;
              final initial =
                  shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S';

              return Container(
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
                    GestureDetector(
                      onTap: () {
                        controller.changePage(4);
                        Navigator.pop(Get.context!);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: () {
                            final photoUrl = (controller.userProfile['user']
                                        ?['profile_photo'] ??
                                    '')
                                .toString();
                            if (photoUrl.isNotEmpty) {
                              return Image.network(photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                      child: Text(initial,
                                          style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF9C27B0)))));
                            }
                            return Center(
                                child: Text(initial,
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C27B0))));
                          }(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Obx(() =>
                _buildDrawerItem(0, Icons.dashboard, 'Dashboard', controller, context)),
            Obx(() =>
                _buildDrawerItem(1, Icons.work, 'Jobs', controller, context)),
            Obx(() => _buildDrawerItem(
                2, Icons.search, 'Find Installers', controller, context)),
            Obx(() => _buildDrawerItem(
                3, Icons.notifications, 'Notifications', controller, context)),
            Obx(() => _buildDrawerItem(
                4, Icons.person, 'My Profile', controller, context)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFF44336)),
                title: const Text('Logout',
                    style: TextStyle(color: Color(0xFFF44336))),
                onTap: () {
                  GetStorage().remove('token');
                  GetStorage().remove('user');
                  Get.offAllNamed('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title,
      ShopkeeperController controller, BuildContext context) {
    final isSelected = controller.currentIndex.value == index;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? const Color(0xFF9C27B0) : Colors.grey),
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
    final ShopkeeperController controller = Get.find<ShopkeeperController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.dashboardData.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF9C27B0)));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchDashboard();
              await controller.fetchProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, controller),
                  const SizedBox(height: 16),
                  _buildStatsCards(controller),
                  const SizedBox(height: 20),
                  _buildRecentJobs(controller),
                  const SizedBox(height: 20),
                  _buildQuickActions(controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ShopkeeperController controller) {
    final profileUser = controller.userProfile['user'];
    final dashUser = controller.dashboardData['user'];
    final storage = GetStorage();
    final storedUser = storage.read('user');
    final userName = profileUser?['name'] ??
        dashUser?['name'] ??
        storedUser?['name'] ??
        'Shopkeeper';
    final shopName = controller.userProfile['profile']?['shop_name'];
    final displayName = shopName ?? userName;
    final email = profileUser?['email'] ??
        dashUser?['email'] ??
        storedUser?['email'] ??
        '';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $displayName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(email,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Obx(() {
            final unread = controller.unreadNotifications.value;
            return GestureDetector(
              onTap: () => controller.changePage(3),
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF9C27B0)),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$unread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(width: 8),
          Obx(() {
            final photoUrl =
                (controller.userProfile['user']?['profile_photo'] ?? '')
                    .toString();
            return GestureDetector(
              onTap: () => controller.changePage(4),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Color(0xFFF3E5F5), shape: BoxShape.circle),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Text(initial,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9C27B0)))))
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C27B0)))),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ShopkeeperController controller) {
    // Backend returns flat keys directly in dashboardData
    final totalJobs = controller.dashboardData['jobs_posted'] ?? 0;
    final activeJobs = controller.dashboardData['active_jobs'] ?? 0;
    final completedJobs = controller.dashboardData['completed_jobs'] ?? 0;
    final totalSpent = controller.dashboardData['total_payments_made'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatCard(
              Icons.work, const Color(0xFF9C27B0), 'Total Jobs', '$totalJobs'),
          _buildStatCard(Icons.play_circle, const Color(0xFF2196F3),
              'Active Jobs', '$activeJobs'),
          _buildStatCard(Icons.check_circle, const Color(0xFF4CAF50),
              'Completed', '$completedJobs'),
          _buildStatCard(Icons.payments, const Color(0xFFFF9800), 'Total Paid',
              'PKR $totalSpent'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, Color color, String title, String value) {
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
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentJobs(ShopkeeperController controller) {
    final recentJobs =
        controller.dashboardData['recent_jobs'] as List? ?? [];

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
                const Text('Recent Jobs',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () =>
                      Get.find<ShopkeeperController>().changePage(1),
                  child: const Text('View all',
                      style: TextStyle(color: Color(0xFF9C27B0))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentJobs.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Icon(Icons.work_off, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No jobs posted yet',
                      style: TextStyle(color: Colors.grey)),
                ]),
              ))
            else
              ...recentJobs.take(3).map((job) => _buildJobItem(job as Map, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildJobItem(Map job, ShopkeeperController controller) {
    final status = job['status']?.toString() ?? '';
    Color statusColor;
    switch (status) {
      case 'active':
      case 'open':
        statusColor = const Color(0xFF2196F3);
        break;
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        break;
      default:
        statusColor = const Color(0xFFFF9800);
    }

    return GestureDetector(
      onTap: () {
        // Navigate to jobs page and open this job's detail
        controller.changePage(1);
        // Store selected job for JobsPage to open
        controller.pendingJobDetail.value =
            Map<String, dynamic>.from(job as Map);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.work, color: Color(0xFF9C27B0), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title']?.toString() ?? 'Job',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('PKR ${job['budget'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ]),
            ),
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.isEmpty
                      ? 'N/A'
                      : status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: Colors.grey),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ShopkeeperController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _buildQuickAction(Icons.add, 'Post Job',
                    const Color(0xFF9C27B0), () {
              controller.changePage(1);
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickAction(Icons.search, 'Find Installers',
                    const Color(0xFF2196F3), () {
              controller.changePage(2);
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _buildQuickAction(
                    Icons.list, 'My Jobs', const Color(0xFF4CAF50), () {
              controller.changePage(1);
            })),
          ]),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      ),
    );
  }
}
