import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InstallerController controller = Get.find<InstallerController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    if (controller.myJobs.isEmpty) {
      controller.fetchMyJobs();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List _jobsForTab(List jobs) {
    switch (_tabController.index) {
      case 1:
        return jobs.where((j) {
          final s = (j['status'] ?? '').toString().toLowerCase();
          return s == 'active' || s == 'in_progress' || s == 'in progress' || s == 'started';
        }).toList();
      case 2:
        return jobs.where((j) {
          final s = (j['status'] ?? '').toString().toLowerCase();
          return s == 'completed';
        }).toList();
      default:
        return jobs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildTabs(),
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
                color: const Color(0xFFFF8F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Jobs',
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

  Widget _buildStatsCards() {
    return Obx(() {
      final stats = controller.dashboardData['stats'] as Map? ?? {};
      final total = stats['total_jobs']?.toString() ??
          stats['total']?.toString() ??
          controller.myJobs.length.toString();
      final active = stats['active_jobs']?.toString() ??
          stats['active']?.toString() ??
          controller.myJobs
              .where((j) {
                final s = (j['status'] ?? '').toString().toLowerCase();
                return s == 'active' || s == 'in_progress' || s == 'in progress' || s == 'started';
              })
              .length
              .toString();
      final completed = stats['completed_jobs']?.toString() ??
          stats['completed']?.toString() ??
          controller.myJobs
              .where((j) => (j['status'] ?? '').toString().toLowerCase() == 'completed')
              .length
              .toString();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard('Total', total, const Color(0xFF2196F3)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Active', active, const Color(0xFFFF8F00)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Completed', completed, const Color(0xFF4CAF50)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildTabButton('All', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Active', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Completed', 2),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsList(),
                  _buildJobsList(),
                  _buildJobsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _tabController.index == index
                ? const Color(0xFFFF8F00)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _tabController.index == index
                    ? Colors.white
                    : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    return Obx(() {
      if (controller.myJobsLoading.value && controller.myJobs.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
        );
      }

      final tabJobs = _jobsForTab(controller.myJobs.toList());

      if (tabJobs.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No jobs found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFFFF8F00),
        onRefresh: () => controller.fetchMyJobs(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tabJobs.length,
          itemBuilder: (context, index) {
            final assignment = tabJobs[index] as Map;
            final job = assignment['job'] as Map? ?? assignment;
            final status = assignment['status'] ?? job['status'] ?? '';
            final title = job['title'] ?? 'Untitled Job';
            final description = job['description'] ?? '';
            final city = job['city'] ?? '';
            final location = job['location'] ?? '';
            final displayLocation = city.isNotEmpty
                ? '$city${location.isNotEmpty ? ', $location' : ''}'
                : location;
            final budget = job['budget'];
            final amountText = budget != null ? 'Rs $budget' : 'N/A';
            final assignmentId = assignment['id'] ?? job['id'];
            final isCompleted =
                status.toString().toLowerCase() == 'completed';
            final isActive = status.toString().toLowerCase() == 'active' ||
                status.toString().toLowerCase() == 'in_progress' ||
                status.toString().toLowerCase() == 'in progress' ||
                status.toString().toLowerCase() == 'started';
            final isPending = !isCompleted && !isActive;
            final assignStatus = status.toString().toLowerCase();
            final paymentSent = job['payment_released_at'] != null;
            final paymentDone = job['payment_received_at'] != null;

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title.toString(),
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
                          color: _getStatusColor(status.toString()).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatStatus(status.toString()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(status.toString()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description.toString(),
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayLocation.isNotEmpty ? displayLocation : 'N/A',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        amountText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),
                  if (!paymentDone) ...[
                    const SizedBox(height: 12),
                    if (assignStatus == 'pending')
                      _jobStatusLabel('Awaiting Shopkeeper Acceptance', Colors.grey),
                    if (assignStatus == 'accepted')
                      _jobActionButton(
                        'Start Job',
                        const Color(0xFF2196F3),
                        () => controller.startJob(int.parse(assignmentId.toString())),
                      ),
                    if (assignStatus == 'in_progress')
                      _jobActionButton(
                        'Mark as Completed',
                        const Color(0xFFFF8F00),
                        () => _showCompleteDialog(context, int.parse(assignmentId.toString())),
                      ),
                    if (assignStatus == 'completed' && !paymentSent)
                      _jobStatusLabel('Awaiting Payment from Shopkeeper', const Color(0xFFFF9800)),
                    if (paymentSent && !paymentDone)
                      _jobActionButton(
                        'Mark Payment Received',
                        const Color(0xFF4CAF50),
                        () => _showPaymentReceivedDialog(
                          context,
                          int.parse((job['job_id'] ?? job['id']).toString()),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  void _showCompleteDialog(BuildContext context, int jobId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text('Mark this job as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.completeJob(jobId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentReceivedDialog(BuildContext context, int jobId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment Received'),
        content: const Text('Confirm that you have received the payment outside the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.confirmPaymentReceived(jobId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _jobStatusLabel(String text, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 12),
    ),
  );

  Widget _jobActionButton(String label, Color color, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    ),
  );

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'in_progress' || s == 'in progress' || s == 'active' || s == 'started') {
      return const Color(0xFFFF8F00);
    }
    if (s == 'completed') {
      return const Color(0xFF4CAF50);
    }
    return Colors.grey;
  }

  String _formatStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'in_progress') return 'In Progress';
    return status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : status;
  }
}
