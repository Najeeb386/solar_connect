import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class BrandProfilePage extends StatefulWidget {
  const BrandProfilePage({super.key});

  @override
  State<BrandProfilePage> createState() => _BrandProfilePageState();
}

class _BrandProfilePageState extends State<BrandProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initControllers(Map userProfile) {
    if (_initialized) return;
    _initialized = true;
    final user = userProfile['user'] as Map? ?? {};
    final profile = userProfile['profile'] as Map? ?? {};
    _nameController.text = profile['company_name'] ?? user['name'] ?? '';
    _websiteController.text = profile['website'] ?? '';
    _descriptionController.text = profile['description'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          final userProfile = controller.userProfile;
          if (userProfile.isNotEmpty) _initControllers(Map.from(userProfile));
          final user = userProfile['user'] as Map? ?? {};
          final profile = userProfile['profile'] as Map? ?? {};
          final companyName = profile['company_name'] ?? user['name'] ?? 'Brand';
          final email = user['email'] ?? '';
          final verificationStatus = profile['domain_verification_status'] ?? 'pending';
          final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'B';

          return Column(
            children: [
              _buildHeader(context),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                      child: Center(
                        child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(companyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: verificationStatus == 'verified'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Domain: $verificationStatus',
                              style: TextStyle(
                                fontSize: 12,
                                color: verificationStatus == 'verified' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
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
                            _buildTabButton('Basic Info', 0),
                            const SizedBox(width: 8),
                            _buildTabButton('Settings', 1),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBasicInfoTab(controller),
                            _buildSettingsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
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
          const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
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
            color: _tabController.index == index ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _tabController.index == index ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(BrandController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Company Name *', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: _nameController, decoration: _inputDecoration('Company name')),
          const SizedBox(height: 16),
          const Text('Website', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: _websiteController, keyboardType: TextInputType.url, decoration: _inputDecoration('https://your-website.com')),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: _descriptionController, maxLines: 3, decoration: _inputDecoration('About your brand...')),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final data = <String, dynamic>{
                  'company_name': _nameController.text.trim(),
                  'website': _websiteController.text.trim(),
                  'description': _descriptionController.text.trim(),
                };
                await controller.updateProfile(data);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSettingItem(Icons.notifications, 'Notifications', true),
          _buildSettingItem(Icons.email, 'Email Notifications', true),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Get.offAllNamed('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool value) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
      ),
      title: Text(title),
      trailing: Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFF2196F3)),
      contentPadding: EdgeInsets.zero,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
