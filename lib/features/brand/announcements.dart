import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showCreateForm)
              Expanded(child: _buildCreateForm(controller))
            else
              Expanded(child: _buildAnnouncementsList(controller)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
        backgroundColor: const Color(0xFF2196F3),
        icon: Icon(_showCreateForm ? Icons.list : Icons.add, color: Colors.white),
        label: Text(
          _showCreateForm ? 'View Announcements' : 'New Announcement',
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
          const Text('Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCreateForm(BrandController controller) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isPinned = false;
    bool isSubmitting = false;

    return StatefulBuilder(builder: (context, setInnerState) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Title *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(controller: titleController, decoration: _inputDecoration('e.g. New Solar Product Line Available')),
              const SizedBox(height: 16),
              const Text('Body *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(controller: bodyController, maxLines: 4, decoration: _inputDecoration('Write your announcement content here...')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: isPinned,
                    onChanged: (v) => setInnerState(() => isPinned = v),
                    activeColor: const Color(0xFF2196F3),
                  ),
                  const Text('Pin this announcement (shows at top)'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showCreateForm = false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () async {
                        if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Title and body are required', snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        setInnerState(() => isSubmitting = true);
                        final success = await controller.createAnnouncement({
                          'title': titleController.text.trim(),
                          'body': bodyController.text.trim(),
                          'is_pinned': isPinned,
                        });
                        setInnerState(() => isSubmitting = false);
                        if (success && mounted) {
                          titleController.clear();
                          bodyController.clear();
                          setState(() => _showCreateForm = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Post Announcement', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildAnnouncementsList(BrandController controller) {
    return Obx(() {
      if (controller.announcementsLoading.value && controller.announcements.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
      }
      if (controller.announcements.isEmpty) {
        return const Center(child: Text('No announcements yet', style: TextStyle(color: Colors.grey)));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchAnnouncements(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            final item = controller.announcements[index] as Map;
            final isPinned = item['is_pinned'] == true;
            final isActive = item['status'] == 'active';
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                  Row(
                    children: [
                      if (isPinned) ...[
                        const Icon(Icons.push_pin, size: 16, color: Color(0xFFFF9800)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(item['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['status'] ?? '',
                          style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF4CAF50) : Colors.grey),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Announcement'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            controller.deleteAnnouncement(item['id'] as int);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['body'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(item['created_at']?.toString().split('T').first ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
