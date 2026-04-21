import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/shopkeeper_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShopkeeperController>();

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
                      child: CircularProgressIndicator(
                          color: Color(0xFF9C27B0)));
                }
                if (controller.notifications.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF9C27B0),
                    onRefresh: controller.fetchNotifications,
                    child: ListView(children: const [
                      SizedBox(height: 120),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No notifications yet',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15)),
                          ]),
                    ]),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF9C27B0),
                  onRefresh: controller.fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final n = Map<String, dynamic>.from(
                          controller.notifications[index] as Map);
                      return _buildNotificationCard(n);
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

  Widget _buildHeader(
      BuildContext context, ShopkeeperController controller) {
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
          const Text('Notifications',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          Obx(() {
            final count = controller.unreadNotifications.value;
            return count > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12)),
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

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type']?.toString() ?? 'general';
    final isRead = notification['is_read'] == true;
    final title = notification['title']?.toString() ?? 'Notification';
    final message = notification['message']?.toString() ?? '';
    final createdAt = notification['created_at']?.toString() ?? '';
    final displayDate =
        createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

    final color = _typeColor(type);
    final icon = _typeIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14))),
                  if (!isRead)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFF9C27B0),
                            shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 4),
                Text(message,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(displayDate,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'job':
        return const Color(0xFF2196F3);
      case 'payment':
        return const Color(0xFF9C27B0);
      case 'completion':
        return const Color(0xFF4CAF50);
      case 'dispute':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'job':
        return Icons.work;
      case 'payment':
        return Icons.payments;
      case 'completion':
        return Icons.check_circle;
      case 'dispute':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }
}
