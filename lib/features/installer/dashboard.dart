import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/widgets/storage_image.dart';
import 'available_jobs.dart';
import 'my_jobs.dart';
import 'my_profile.dart';
import 'wallet.dart';
import 'nearby_shops.dart';
import 'installer_program.dart';
import 'qr_reward.dart';
import 'controllers/installer_controller.dart';

final List<Widget> _pages = [
  const DashboardHome(),
  const AvailableJobsPage(),
  const MyJobsPage(),
  const MyProfilePage(),
  const WalletPage(),
  const NearbyShopsPage(),
  const InstallerProgramPage(),
  const QRRewardPage(),
];

class InstallerDashboard extends StatelessWidget {
  const InstallerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final InstallerController controller = Get.find<InstallerController>();

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

  Widget _buildDrawer(BuildContext context, InstallerController controller) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Obx(() {
              // Read from userProfile first (updated on profile save), then dashboard, then storage
              final profileUser = controller.userProfile['user'];
              final dashUser = controller.dashboardData['user'];
              final storage = GetStorage();
              final storedUser = storage.read('user');

              final userName =
                  profileUser?['name'] ??
                  dashUser?['name'] ??
                  storedUser?['name'] ??
                  'Installer';
              final userEmail =
                  profileUser?['email'] ??
                  dashUser?['email'] ??
                  storedUser?['email'] ??
                  '';
              final kycStatus =
                  controller.dashboardData['kyc_status']?.toString() ?? '';
              final userStatus =
                  profileUser?['status']?.toString() ??
                  dashUser?['status']?.toString() ??
                  storedUser?['status']?.toString() ??
                  'active';
              final initial = userName.isNotEmpty
                  ? userName[0].toUpperCase()
                  : 'I';
              final photoUrl =
                  profileUser?['profile_photo']?.toString() ??
                  dashUser?['profile_photo']?.toString() ??
                  storedUser?['profile_photo']?.toString() ??
                  '';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
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
                      clipBehavior: Clip.antiAlias,
                      child: photoUrl.isNotEmpty
                          ? StorageImage(
                              url: photoUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8F00),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8F00),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Account status badge
                    _buildStatusBadge(userStatus, kycStatus),
                  ],
                ),
              );
            }),
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
                Icons.work,
                'Available Jobs',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                2,
                Icons.assignment,
                'My Jobs',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                3,
                Icons.person,
                'My Profile',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                4,
                Icons.account_balance_wallet,
                'Wallet',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                5,
                Icons.store,
                'Nearby Shops',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                6,
                Icons.school,
                'Installer Program',
                controller,
                context,
              ),
            ),
            Obx(
              () => _buildDrawerItem(
                7,
                Icons.qr_code,
                'Claim Reward',
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

  Widget _buildStatusBadge(String userStatus, String kycStatus) {
    // Priority: suspended > active(kyc approved) > in review > not verified
    final IconData icon;
    final String label;
    final Color bg;
    final Color border;

    if (userStatus == 'suspended') {
      icon = Icons.block;
      label = 'Suspended';
      bg = Colors.red.withValues(alpha: 0.35);
      border = Colors.redAccent.withValues(alpha: 0.7);
    } else if (kycStatus == 'approved') {
      icon = Icons.verified_user;
      label = 'Active';
      bg = Colors.green.withValues(alpha: 0.3);
      border = Colors.greenAccent.withValues(alpha: 0.6);
    } else if (kycStatus == 'pending') {
      icon = Icons.hourglass_top_rounded;
      label = 'In Review';
      bg = Colors.amber.withValues(alpha: 0.35);
      border = Colors.amberAccent.withValues(alpha: 0.7);
    } else {
      // not_submitted or rejected
      icon = Icons.warning_amber_rounded;
      label = 'Not Verified';
      bg = Colors.orange.withValues(alpha: 0.3);
      border = Colors.orangeAccent.withValues(alpha: 0.6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    int index,
    IconData icon,
    String title,
    InstallerController controller,
    BuildContext context,
  ) {
    final isSelected = controller.currentIndex.value == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFFF8F00) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFF8F00) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFF8F00).withValues(alpha: 0.1),
      onTap: () {
        controller.changePage(index);
        Navigator.pop(context);
      },
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final InstallerController controller = Get.find<InstallerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
            );
          }
          // Check if dashboard data is empty, which indicates API failure
          if (controller.dashboardData.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.fetchDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 100,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.fetchDashboard,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  _buildKycBanner(controller),
                  const SizedBox(height: 20),
                  _buildOffersSlider(),
                  const SizedBox(height: 20),
                  _buildStatsCards(controller),
                  const SizedBox(height: 24),
                  Obx(() => _buildBigCards(controller)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InstallerController controller) {
    // Prefer profile data (updated after photo upload) over dashboard data
    final profileUser = controller.userProfile['user'];
    final dashUser = controller.dashboardData['user'];
    final userName = profileUser?['name'] ?? dashUser?['name'] ?? 'Installer';
    final userEmail = profileUser?['email'] ?? dashUser?['email'] ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'I';
    final photoUrl =
        profileUser?['profile_photo']?.toString() ??
        dashUser?['profile_photo']?.toString() ??
        '';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Avatar: photo if available, initial letter otherwise
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl.isNotEmpty
                ? StorageImage(
                    url: photoUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8F00),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycBanner(InstallerController controller) {
    final kycStatus = controller.dashboardData['kyc_status']?.toString() ?? '';

    // ── APPROVED: HIDE banner completely ──────────────────────────────
    if (kycStatus == 'approved') {
      return const SizedBox.shrink();
    }

    // ── NOT APPROVED: RED warning banner ──────────────────────────────
    final bool isPending = kycStatus == 'pending';

    return _kycBannerTile(
      color: const Color(0xFFFFEBEE),
      border: Colors.red,
      icon: isPending
          ? Icons.hourglass_top_rounded
          : Icons.warning_amber_rounded,
      iconColor: Colors.red,
      title: isPending ? 'KYC Under Review' : 'KYC Not Verified',
      subtitle: isPending
          ? 'Your documents are under review. Please wait.'
          : 'Complete your KYC to start accepting jobs!',
      titleColor: Colors.red.shade800,
      subtitleColor: Colors.red.shade700,
      onTap: () => controller.changePage(3),
      onDismiss: null,
    );
  }

  Widget _kycBannerTile({
    required Color color,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color subtitleColor,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.fromLTRB(16, 12, onDismiss != null ? 8 : 16, 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: subtitleColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 18, color: iconColor),
              )
            else if (onTap != null)
              Icon(Icons.chevron_right, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersSlider() {
    final controller = Get.find<InstallerController>();

    return Obx(() {
      if (controller.programsLoading.value) {
        return const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      final programs = controller.topPrograms.take(3).toList();

      final offers = programs.isNotEmpty
          ? programs.map((p) {
              final reward =
                  double.tryParse(p['reward']?.toString() ?? '0') ?? 0;
              final colors = [
                const Color(0xFFE91E63),
                const Color(0xFF2196F3),
                const Color(0xFFFF5722),
                const Color(0xFF00BCD4),
                const Color(0xFF4CAF50),
              ];
              final colorIndex = programs.indexOf(p) % colors.length;
              return {
                'title': 'Rs ${reward.toStringAsFixed(0)} Reward',
                'subtitle': p['title']?.toString() ?? 'Program',
                'brand': p['brand_name']?.toString() ?? 'Brand',
                'color': colors[colorIndex],
                'id': p['id'],
              };
            }).toList()
          : [
              {
                'title': 'Earn Rs 500',
                'subtitle': 'Solar Panel Install',
                'brand': 'EcoSolar',
                'color': const Color(0xFFE91E63),
              },
              {
                'title': 'Earn Rs 1000',
                'subtitle': 'Inverter Setup',
                'brand': 'Tesla',
                'color': const Color(0xFF2196F3),
              },
              {
                'title': 'Earn Rs 1500',
                'subtitle': 'Battery Install',
                'brand': 'Huawei',
                'color': const Color(0xFFFF5722),
              },
            ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CarouselSlider.builder(
              itemCount: offers.length,
              options: CarouselOptions(
                height: 140,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
              ),
              itemBuilder: (context, index, realIndex) {
                final offer = offers[index];
                return GestureDetector(
                  onTap: () => controller.changePage(6),
                  child: _buildOfferCard(offer),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [offer['color'], offer['color'].withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: offer['color'].withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              offer['brand'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                offer['subtitle'],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(InstallerController controller) {
    final stats = controller.dashboardData['stats'] ?? {};
    final pendingJobs = stats['pending_jobs'] ?? 0;
    final activeJobs = stats['active_jobs'] ?? 0;
    final completedJobs = stats['completed_jobs'] ?? 0;
    final walletBalance = stats['wallet_balance'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions,
                  iconColor: const Color(0xFFFF8F00),
                  title: 'Pending Jobs',
                  value: '$pendingJobs',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.play_circle_outline,
                  iconColor: const Color(0xFF2196F3),
                  title: 'Active Jobs',
                  value: '$activeJobs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'Completed Jobs',
                  value: '$completedJobs',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Wallet Balance',
                  value: 'Rs $walletBalance',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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

  Widget _buildBigCards(InstallerController controller) {
    final recentJobs = controller.dashboardData['recent_jobs'] as List? ?? [];
    final availableJobs =
        controller.dashboardData['available_jobs'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildBigCard(
            title: 'Recent Jobs',
            icon: Icons.assignment,
            items: recentJobs.isEmpty
                ? [
                    {'name': 'No recent jobs', 'location': '', 'status': ''},
                  ]
                : recentJobs
                      .take(2)
                      .map(
                        (job) => {
                          'name': job['title'] ?? 'Job',
                          'location': job['location'] ?? '',
                          'status': job['status'] ?? '',
                        },
                      )
                      .toList()
                      .cast<Map<String, dynamic>>(),
          ),
          const SizedBox(height: 16),
          _buildBigCard(
            title: 'Available Jobs',
            icon: Icons.work,
            items: availableJobs.isEmpty
                ? [
                    {'name': 'No available jobs', 'location': '', 'status': ''},
                  ]
                : availableJobs
                      .take(2)
                      .map(
                        (job) => {
                          'name': job['title'] ?? 'Job',
                          'location': job['location'] ?? '',
                          'status': 'View Details',
                        },
                      )
                      .toList()
                      .cast<Map<String, dynamic>>(),
          ),
        ],
      ),
    );
  }

  Widget _buildBigCard({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
  }) {
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFFF8F00), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8F00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          item['location']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['status']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF8F00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
