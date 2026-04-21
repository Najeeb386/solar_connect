import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/shopkeeper_controller.dart';

class ShopkeepersPage extends StatefulWidget {
  const ShopkeepersPage({super.key});

  @override
  State<ShopkeepersPage> createState() => _ShopkeepersPageState();
}

class _ShopkeepersPageState extends State<ShopkeepersPage> {
  final ShopkeeperController controller = Get.find<ShopkeeperController>();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (controller.installers.isEmpty) {
      controller.fetchInstallers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.installersLoading.value &&
                    controller.installers.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF9C27B0)));
                }

                final filtered = controller.installers.where((i) {
                  final inst = i as Map;
                  final name =
                      inst['name']?.toString().toLowerCase() ?? '';
                  final skills =
                      inst['skills']?.toString().toLowerCase() ?? '';
                  final city =
                      inst['city']?.toString().toLowerCase() ?? '';
                  return _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase()) ||
                      skills.contains(_searchQuery.toLowerCase()) ||
                      city.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF9C27B0),
                    onRefresh: () => controller.fetchInstallers(),
                    child: ListView(children: const [
                      SizedBox(height: 100),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No installers found',
                                style: TextStyle(color: Colors.grey)),
                          ]),
                    ]),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF9C27B0),
                  onRefresh: () => controller.fetchInstallers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final installer = Map<String, dynamic>.from(
                          filtered[index] as Map);
                      return _buildInstallerCard(installer);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Find Installers',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Obx(() => Text(
                    '${controller.installers.length} available',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by name, skills or city...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  })
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildInstallerCard(Map<String, dynamic> installer) {
    final name = installer['name']?.toString() ?? 'Installer';
    final city = installer['city']?.toString() ?? '';
    final region = installer['region']?.toString() ?? '';
    final skills = installer['skills']?.toString() ?? '';
    final rating =
        double.tryParse(installer['rating']?.toString() ?? '0') ?? 0.0;
    final jobsDone = installer['total_jobs_completed'] ?? 0;
    final kycStatus = installer['kyc_status']?.toString() ?? '';
    final isVerified = kycStatus == 'approved';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
    final location =
        [city, region].where((s) => s.isNotEmpty).join(', ');

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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    const Color(0xFF9C27B0).withValues(alpha: 0.1),
                child: Text(initial,
                    style: const TextStyle(
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified,
                            size: 16, color: Color(0xFF4CAF50)),
                      ],
                    ]),
                    if (location.isNotEmpty)
                      Text(location,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                  Text('$jobsDone jobs',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.build, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(skills,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis)),
            ]),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showInstallerDetail(installer),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Profile',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showInstallerDetail(Map<String, dynamic> installer) async {
    final id = installer['id'];
    if (id == null) return;

    Get.dialog(
        const Center(
            child:
                CircularProgressIndicator(color: Color(0xFF9C27B0))),
        barrierDismissible: false);

    final detail =
        await controller.getInstallerDetail(int.parse(id.toString()));
    Get.back();

    if (detail == null) {
      Get.snackbar('Error', 'Could not load installer profile',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final name = detail['name']?.toString() ?? 'Installer';
    final email = detail['email']?.toString() ?? '';
    final phone = detail['phone']?.toString() ?? '';
    final city = detail['city']?.toString() ?? '';
    final region = detail['region']?.toString() ?? '';
    final profile = detail['profile'] as Map? ?? {};
    final skills = profile['skills']?.toString() ?? '';
    final bio = profile['bio']?.toString() ?? '';
    final rating =
        double.tryParse(profile['rating']?.toString() ?? '0') ?? 0.0;
    final jobsDone = profile['total_jobs_completed'] ?? 0;
    final kycStatus = profile['kyc_status']?.toString() ?? '';
    final isVerified = kycStatus == 'approved';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    child: Text(initial,
                        style: const TextStyle(
                            color: Color(0xFF9C27B0),
                            fontWeight: FontWeight.bold,
                            fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                size: 18, color: Color(0xFF4CAF50)),
                          ],
                        ]),
                        if (email.isNotEmpty)
                          Text(email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        Row(children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text('$rating  ·  $jobsDone jobs done',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (phone.isNotEmpty)
                _detailRow(Icons.phone, 'Phone', phone),
              if (city.isNotEmpty)
                _detailRow(Icons.location_on, 'Location',
                    [city, region].where((s) => s.isNotEmpty).join(', ')),
              if (skills.isNotEmpty)
                _detailRow(Icons.build, 'Skills', skills),
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('About',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(bio, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9C27B0)),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
