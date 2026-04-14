import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'New Solar Panel Models Available',
      'body':
          'We have introduced new models for the upcoming season with better efficiency.',
      'date': '2025-04-10',
      'status': 'Published',
      'pinned': true,
    },
    {
      'title': 'Price Update Notice',
      'body':
          'Effective from next month, there will be a 10% price adjustment.',
      'date': '2025-04-05',
      'status': 'Published',
      'pinned': false,
    },
    {
      'title': 'Holiday Schedule',
      'body':
          'Our support team will have limited availability during the holiday period.',
      'date': '2025-04-01',
      'status': 'Published',
      'pinned': false,
    },
    {
      'title': 'New Partner Program',
      'body': 'We are launching a new partner program for installers.',
      'date': '2025-03-25',
      'status': 'Draft',
      'pinned': false,
    },
  ];

  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showCreateForm)
              Expanded(child: _buildCreateForm())
            else
              Expanded(child: _buildAnnouncementsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
        backgroundColor: const Color(0xFF2196F3),
        icon: Icon(
          _showCreateForm ? Icons.list : Icons.add,
          color: Colors.white,
        ),
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
          const Text(
            'Announcements',
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

  Widget _buildCreateForm() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final linkController = TextEditingController();
    bool isPinned = false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Announcement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFFFF9800), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your announcement will be reviewed by an admin before publishing.',
                      style: TextStyle(fontSize: 13, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Title *',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                'e.g. New Solar Product Line Available',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Body *', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Write your announcement content here...',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Link URL (optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: linkController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration('https://example.com/more-info'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Expires At (optional)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              decoration: _inputDecoration('mm/dd/yyyy'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: isPinned,
                  onChanged: (v) {},
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
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Success',
                        'Announcement submitted for review!',
                        backgroundColor: const Color(0xFF4CAF50),
                        colorText: Colors.white,
                      );
                      setState(() => _showCreateForm = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit for Review',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final item = _announcements[index];
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (item['pinned']) ...[
                    const Icon(
                      Icons.push_pin,
                      size: 16,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item['status'] == 'Published'
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 11,
                        color: item['status'] == 'Published'
                            ? const Color(0xFF4CAF50)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item['body'],
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                item['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
