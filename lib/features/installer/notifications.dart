import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class InstallerNotificationsPage extends StatelessWidget {
  const InstallerNotificationsPage({super.key});

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
                if (controller.notificationsLoading.value &&
                    controller.notifications.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
                }
                if (controller.notifications.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF3B82F6),
                    onRefresh: controller.fetchNotifications,
                    child: ListView(children: const [
                      SizedBox(height: 120),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No notifications yet',
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ]),
                    ]),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  onRefresh: controller.fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final n = Map<String, dynamic>.from(
                          controller.notifications[index] as Map);
                      return _buildCard(n);
                    },
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Notifications',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Obx(() {
            final count = controller.unreadCount.value;
            return count > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text('$count new',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> n) {
    final type = n['type']?.toString() ?? 'general';
    final isRead = n['is_read'] == true;
    final title = n['title']?.toString() ?? 'Notification';
    final message = n['message']?.toString() ?? '';
    final createdAt = n['created_at']?.toString() ?? '';
    final date = createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;
    final color = _typeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon(type), color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14))),
              if (!isRead)
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6), shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(message,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
      ]),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'job': return const Color(0xFF3B82F6);
      case 'payment': return const Color(0xFF8B5CF6);
      case 'completion': return const Color(0xFF4CAF50);
      case 'dispute': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'job': return Icons.work;
      case 'payment': return Icons.payments;
      case 'completion': return Icons.check_circle;
      case 'dispute': return Icons.warning;
      default: return Icons.notifications;
    }
  }
}
