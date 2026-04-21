import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/storage_image.dart';
import 'controllers/installer_controller.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  InstallerController get _controller => Get.find<InstallerController>();

  // Basic info controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();

  // KYC controllers
  final _cnicController = TextEditingController();
  XFile? _cnicFrontFile;
  XFile? _cnicBackFile;
  Uint8List? _cnicFrontBytes;
  Uint8List? _cnicBackBytes;

  // Bank controllers
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  String _selectedPaymentType = 'easypaisa';

  bool _profileLoaded = false;
  bool _kycLoaded = false;
  bool _bankLoaded = false;

  Map _kycData = {};
  List _paymentMethods = [];

  bool _isSavingProfile = false;
  bool _isSubmittingKyc = false;
  bool _isSavingBank = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
      if (_tabController.index == 0 && !_profileLoaded) _loadProfile();
      if (_tabController.index == 1 && !_kycLoaded) _loadKyc();
      if (_tabController.index == 2 && !_bankLoaded) _loadBank();
    });
    _loadProfile();
    _loadKyc();
    _loadBank();
  }

  Future<void> _loadProfile() async {
    await _controller.fetchProfile();
    final profile = _controller.userProfile;
    if (profile.isNotEmpty) {
      final user = profile['user'] ?? {};
      final prof = profile['profile'] ?? {};
      setState(() {
        _nameController.text = user['name'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _cityController.text = user['city'] ?? '';
        _regionController.text = user['region'] ?? '';
        _bioController.text = prof['bio'] ?? '';
        _skillsController.text = prof['skills'] ?? '';
        _profileLoaded = true;
      });
    }
  }

  Future<void> _loadKyc() async {
    final res = await _controller.fetchKycStatus();
    if (res != null) {
      setState(() {
        _kycData = res;
        if (res['cnic_number'] != null) {
          _cnicController.text = res['cnic_number'].toString();
        }
        _kycLoaded = true;
      });
    }
  }

  Future<void> _loadBank() async {
    await _controller.fetchPaymentMethods();
    setState(() {
      _paymentMethods = _controller.paymentMethods.toList();
      _bankLoaded = true;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _cnicController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
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
            _buildProfileSummary(),
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
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Change Profile Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFF8F00)),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFF8F00)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null) return;
    setState(() => _isUploadingPhoto = true);
    await _controller.uploadProfilePhoto(picked);
    setState(() => _isUploadingPhoto = false);
  }

  Widget _buildProfileSummary() {
    return Obx(() {
      final user = _controller.userProfile['user'];
      final prof = _controller.userProfile['profile'];
      final storedUser = Get.find<InstallerController>().dashboardData['user'];

      final name = user?['name'] ?? storedUser?['name'] ?? _nameController.text.ifEmpty('Installer');
      final email = user?['email'] ?? storedUser?['email'] ?? '';
      final kycStatus = _kycData['kyc_status']?.toString() ??
          _controller.dashboardData['kyc_status']?.toString() ?? 'not_submitted';
      final balance = prof?['wallet_balance'] ?? _controller.dashboardData['stats']?['wallet_balance'] ?? 0;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
      final photoUrl = user?['profile_photo']?.toString() ?? storedUser?['profile_photo']?.toString();

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Tappable avatar with camera overlay
            GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
              child: Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
                    child: _isUploadingPhoto
                        ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00))))
                        : (photoUrl != null && photoUrl.isNotEmpty)
                            ? ClipOval(child: StorageImage(url: photoUrl, fit: BoxFit.cover, width: 64, height: 64,
                                errorWidget: Center(child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))))))
                            : Center(child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00)))),
                  ),
                  // Camera badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(color: Color(0xFFFF8F00), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (email.isNotEmpty)
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _kycBadge(kycStatus),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Rs ${double.tryParse(balance.toString())?.toStringAsFixed(0) ?? balance}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C27B0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final prof = _controller.userProfile['profile'];
                    final user = _controller.userProfile['user'];
                    final city = user?['city']?.toString() ?? '';
                    final region = user?['region']?.toString() ?? '';
                    final rating = (prof?['rating'] ?? 0).toString();
                    final jobs = (prof?['total_jobs_completed'] ?? 0).toString();
                    final location = [city, region].where((s) => s.isNotEmpty).join(', ');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (location.isNotEmpty) Row(children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star, size: 12, color: Color(0xFFFF8F00)),
                          const SizedBox(width: 3),
                          Text('$rating rating', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 12),
                          const Icon(Icons.check_circle_outline, size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text('$jobs jobs done', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _kycBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        label = '✓ KYC Verified';
        break;
      case 'pending':
        bgColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber[800]!;
        label = '⏳ KYC Pending';
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = '✗ KYC Rejected';
        break;
      default:
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        label = 'KYC Required';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
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
                  _buildTabButton('Basic Info', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('KYC', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Bank Details', 2),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildKycTab(),
                  _buildBankDetailsTab(),
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

  // ── BASIC INFO TAB ──────────────────────────────────────────────────────────

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Full Name *', _nameController),
          const SizedBox(height: 16),
          _buildTextField('Phone', _phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField('City', _cityController),
          const SizedBox(height: 16),
          _buildTextField('Region / Province', _regionController),
          const SizedBox(height: 16),
          const Text('Bio', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tell shopkeepers about yourself...',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Skills', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _skillsController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g. Solar panel installation, Wiring, Inverter setup',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSavingProfile ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSavingProfile
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isSavingProfile = true);
    final success = await _controller.updateProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'region': _regionController.text.trim(),
      'bio': _bioController.text.trim(),
      'skills': _skillsController.text.trim(),
    });
    setState(() => _isSavingProfile = false);
    if (success) await _loadProfile();
  }

  // ── KYC TAB ─────────────────────────────────────────────────────────────────

  Widget _buildKycTab() {
    final status = _kycData['kyc_status']?.toString() ?? 'not_submitted';
    final cnicNumber = _kycData['cnic_number']?.toString() ?? '';

    // Show masked CNIC: first 5 digits visible, rest as *
    String maskedCnic = '';
    if (cnicNumber.isNotEmpty) {
      final digits = cnicNumber.replaceAll('-', '');
      if (digits.length >= 13) {
        maskedCnic = '${cnicNumber.substring(0, 7)}****-${cnicNumber.substring(cnicNumber.lastIndexOf('-') + 1)}';
      } else {
        maskedCnic = cnicNumber.substring(0, (cnicNumber.length / 2).floor()) +
            '*' * (cnicNumber.length - (cnicNumber.length / 2).floor());
      }
    }

    if (status == 'approved') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Approved status banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KYC Verified ✓',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        if (maskedCnic.isNotEmpty)
                          Text(
                            'CNIC: $maskedCnic',
                            style: const TextStyle(color: Colors.green, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Icon(Icons.verified_user, size: 64, color: Color(0xFF4CAF50)),
                  SizedBox(height: 12),
                  Text(
                    'Your identity has been verified.\nYou can now accept jobs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'pending') {
      final frontUrl = _kycData['cnic_front_url']?.toString();
      final backUrl = _kycData['cnic_back_url']?.toString();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Under Review banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.amber[800]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KYC Under Review',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800]),
                        ),
                        const Text(
                          'Your documents are under review. We will notify you once verified.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (cnicNumber.isNotEmpty) ...[
              const Text('CNIC Number', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(maskedCnic.isNotEmpty ? maskedCnic : cnicNumber,
                    style: const TextStyle(fontSize: 15, color: Colors.black87)),
              ),
              const SizedBox(height: 24),
            ],

            _buildServerImage(frontUrl, 'CNIC Front'),
            const SizedBox(height: 16),
            _buildServerImage(backUrl, 'CNIC Back'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // rejected or not_submitted — show upload form
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner (rejection or not_submitted info)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: status == 'rejected'
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'rejected' ? Icons.cancel_outlined : Icons.info_outline,
                  color: status == 'rejected' ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status == 'rejected' ? 'KYC Rejected' : 'KYC Not Submitted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'rejected' ? Colors.red : Colors.grey[700],
                        ),
                      ),
                      if (status == 'rejected' && _kycData['rejection_reason'] != null)
                        Text(
                          'Reason: ${_kycData['rejection_reason']}',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('CNIC Number', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 4),
          const Text('Format: 35201-1234567-1', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _cnicController,
            keyboardType: TextInputType.number,
            inputFormatters: [_CnicInputFormatter()],
            decoration: InputDecoration(
              hintText: '35201-1234567-1',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          const Text('CNIC Front Photo', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          _buildImagePicker('Upload Front Side', _cnicFrontFile, _cnicFrontBytes, () => _pickImage(true)),
          const SizedBox(height: 24),

          const Text('CNIC Back Photo', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          _buildImagePicker('Upload Back Side', _cnicBackFile, _cnicBackBytes, () => _pickImage(false)),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmittingKyc ? null : _submitKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmittingKyc
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Submit KYC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerImage(String? url, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url != null && url.isNotEmpty
              ? Image.network(url, height: 120, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder('Failed to load image'))
              : _imagePlaceholder('No image available'),
        ),
      ],
    );
  }

  Widget _imagePlaceholder(String msg) => Container(
    height: 120, width: double.infinity,
    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
      const SizedBox(height: 8),
      Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        if (isFront) { _cnicFrontFile = picked; _cnicFrontBytes = bytes; }
        else          { _cnicBackFile  = picked; _cnicBackBytes  = bytes; }
      });
    }
  }

  Future<void> _submitKyc() async {
    if (_cnicController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your CNIC number',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_cnicFrontFile == null || _cnicBackFile == null) {
      Get.snackbar('Error', 'Please upload both CNIC front and back photos',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isSubmittingKyc = true);
    final success = await _controller.submitKyc(
      cnicNumber: _cnicController.text.trim(),
      cnicFront: _cnicFrontFile!,
      cnicBack: _cnicBackFile!,
    );
    setState(() => _isSubmittingKyc = false);
    if (success) {
      await _loadKyc();
      await _controller.fetchDashboard();
      Get.snackbar('Submitted', 'KYC submitted — under review',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  Widget _buildImagePicker(String label, XFile? file, Uint8List? bytes, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file != null ? const Color(0xFFFF8F00) : Colors.grey.shade300),
        ),
        child: bytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(bytes, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                  const Text('Tap to select', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
      ),
    );
  }

  // ── BANK DETAILS TAB ────────────────────────────────────────────────────────

  Widget _buildBankDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing payment methods
          if (_paymentMethods.isNotEmpty) ...[
            const Text(
              'Saved Payment Methods',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ..._paymentMethods.map<Widget>((pm) => _buildPaymentMethodCard(pm)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],

          const Text(
            'Add Payment Method',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          const Text('Payment Type', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedPaymentType,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'easypaisa', child: Text('EasyPaisa')),
                DropdownMenuItem(value: 'jazzcash', child: Text('JazzCash')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
              ],
              onChanged: (val) => setState(() => _selectedPaymentType = val!),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Account Name *', _accountNameController),
          const SizedBox(height: 16),
          _buildTextField(
            _selectedPaymentType == 'bank' ? 'Account Number / IBAN' : 'Mobile Number',
            _accountNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSavingBank ? null : _saveBank,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSavingBank
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Save Payment Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map pm) {
    final type = pm['type']?.toString() ?? '';
    final accountName = pm['account_name']?.toString() ?? '';
    final accountNumber = pm['account_number_masked']?.toString() ?? pm['account_number']?.toString() ?? '';
    final isPrimary = pm['is_primary'] == true;

    IconData icon = Icons.account_balance_wallet;
    Color color = const Color(0xFF4CAF50);
    String typeLabel = type.toUpperCase();
    if (type == 'easypaisa') { icon = Icons.phone_android; color = const Color(0xFF4CAF50); typeLabel = 'EasyPaisa'; }
    if (type == 'jazzcash')  { icon = Icons.phone_iphone;  color = const Color(0xFFE91E63); typeLabel = 'JazzCash'; }
    if (type == 'bank')      { icon = Icons.account_balance; color = const Color(0xFF1565C0); typeLabel = 'Bank'; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? const Color(0xFFFF8F00) : Colors.grey.shade200,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Default', style: TextStyle(fontSize: 10, color: Color(0xFFFF8F00), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(accountName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(
                  accountNumber,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isPrimary)
            TextButton(
              onPressed: () async {
                await _controller.setDefaultPaymentMethod(pm['id'] as int);
                await _loadBank();
              },
              child: const Text('Set Default', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _saveBank() async {
    if (_accountNameController.text.trim().isEmpty || _accountNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill in all bank details',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isSavingBank = true);
    final success = await _controller.addPaymentMethod(
      type: _selectedPaymentType,
      accountName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
    );
    setState(() => _isSavingBank = false);
    if (success) {
      _accountNameController.clear();
      _accountNumberController.clear();
      await _loadBank();
    }
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8F00)),
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// Auto-formats CNIC as XXXXX-XXXXXXX-X while typing
class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) buf.write('-');
      buf.write(digits[i]);
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
