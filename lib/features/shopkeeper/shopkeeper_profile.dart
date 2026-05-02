import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'controllers/shopkeeper_controller.dart';
import 'location_picker_screen.dart';

class ShopkeeperProfilePage extends StatefulWidget {
  const ShopkeeperProfilePage({super.key});

  @override
  State<ShopkeeperProfilePage> createState() =>
      _ShopkeeperProfilePageState();
}

class _ShopkeeperProfilePageState extends State<ShopkeeperProfilePage> {
  ShopkeeperController get controller =>
      Get.find<ShopkeeperController>();

  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _descriptionController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _locationLoading = false;

  bool _loaded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!_loaded) {
      await controller.fetchProfile();
    }
    _populateFields();
    setState(() => _loaded = true);
  }

  void _populateFields() {
    final user = controller.userProfile['user'] as Map? ?? {};
    final profile = controller.userProfile['profile'] as Map? ?? {};
    _nameController.text = user['name']?.toString() ?? '';
    _phoneController.text = user['phone']?.toString() ?? '';
    _cityController.text = user['city']?.toString() ?? '';
    _regionController.text = user['region']?.toString() ?? '';
    _shopNameController.text = profile['shop_name']?.toString() ?? '';
    _descriptionController.text = profile['description']?.toString() ?? '';

    // Restore saved location
    final lat = profile['latitude'] ?? user['latitude'];
    final lng = profile['longitude'] ?? user['longitude'];
    _latitude = lat != null ? double.tryParse(lat.toString()) : null;
    _longitude = lng != null ? double.tryParse(lng.toString()) : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Location helpers ────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);

    // Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationLoading = false);
      Get.snackbar(
        'Permission Required',
        'Location permission is permanently denied. Enable it in Settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => Geolocator.openAppSettings(),
          child: const Text('Open Settings',
              style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    if (permission == LocationPermission.denied) {
      setState(() => _locationLoading = false);
      Get.snackbar(
        'Permission Denied',
        'Location permission was denied.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoading = false;
      });
      Get.snackbar(
        'Location Detected',
        'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.85),
        colorText: Colors.white,
        icon: const Icon(Icons.location_on, color: Colors.white),
      );
    } catch (e) {
      setState(() => _locationLoading = false);
      Get.snackbar(
        'Error',
        'Could not get location. Make sure GPS is enabled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Get.to<LatLng>(
      () => LocationPickerScreen(
        initialLat: _latitude,
        initialLng: _longitude,
      ),
    );
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
    });
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }
    if (_shopNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Shop name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'shop_name': _shopNameController.text.trim(),
    };

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) data['phone'] = phone;

    final city = _cityController.text.trim();
    if (city.isNotEmpty) data['city'] = city;

    final region = _regionController.text.trim();
    if (region.isNotEmpty) data['region'] = region;

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) data['description'] = description;

    // Include location if set
    if (_latitude != null && _longitude != null) {
      data['latitude'] = _latitude.toString();
      data['longitude'] = _longitude.toString();
    }

    final success = await controller.updateProfile(data);

    setState(() => _isSaving = false);

    if (success) {
      await Future.delayed(const Duration(milliseconds: 500));
      _populateFields();
    }
  }

  // ─── Photo upload ────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF9C27B0)),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF9C27B0)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) controller.uploadPhoto(image);
  }

  Widget _buildPhotoAvatar(Map user, String initial) {
    final photoUrl = user['profile_photo']?.toString() ?? '';
    return GestureDetector(
      onTap: _pickPhoto,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(initial,
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0))),
                      ),
                    ),
                  )
                : Center(
                    child: Text(initial,
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C27B0)))),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: !_loaded
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF9C27B0)))
                  : RefreshIndicator(
                      onRefresh: _loadProfile,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          _buildProfileCard(),
                          const SizedBox(height: 20),
                          _buildInfoForm(),
                          const SizedBox(height: 20),
                          _buildSettingsCard(),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
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
          const Text('My Profile',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final user = controller.userProfile['user'] as Map? ?? {};
      final profile = controller.userProfile['profile'] as Map? ?? {};
      final name = user['name']?.toString() ?? 'Shopkeeper';
      final email = user['email']?.toString() ?? '';
      final shopName = profile['shop_name']?.toString() ?? name;
      final verificationStatus =
          profile['verification_status']?.toString() ?? 'pending';
      final initial =
          shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S';
      final stats = controller.dashboardData;
      final totalJobs = stats['jobs_posted'] ?? 0;
      final activeJobs = stats['active_jobs'] ?? 0;
      final completedJobs = stats['completed_jobs'] ?? 0;

      return Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            _buildPhotoAvatar(user, initial),
            const SizedBox(height: 12),
            Text(shopName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(email,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: verificationStatus == 'approved'
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                verificationStatus == 'approved'
                    ? 'Verified Shop'
                    : 'Verification Pending',
                style: TextStyle(
                  color: verificationStatus == 'approved'
                      ? const Color(0xFF4CAF50)
                      : Colors.amber[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('$totalJobs', 'Posted'),
                Container(
                    width: 1, height: 30, color: Colors.grey.shade200),
                _statItem('$activeJobs', 'Active'),
                Container(
                    width: 1, height: 30, color: Colors.grey.shade200),
                _statItem('$completedJobs', 'Done'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem(String value, String label) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0))),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }

  Widget _buildInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text('Shop Information',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field('Full Name *', _nameController, Icons.person),
          const SizedBox(height: 12),
          _field('Shop Name', _shopNameController, Icons.store),
          const SizedBox(height: 12),
          _field('Phone', _phoneController, Icons.phone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _field('City', _cityController, Icons.location_city),
          const SizedBox(height: 12),
          _field('Region / Province', _regionController, Icons.map),
          const SizedBox(height: 12),
          const Text('Description',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe your shop...',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationInlineSection(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Location (inline inside form) ───────────────────────────────────────

  Widget _buildLocationInlineSection() {
    final hasLocation = _latitude != null && _longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider with label
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on,
                  color: Color(0xFF9C27B0), size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Shop Location',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(width: 4),
            const Text('(helps installers find you)',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const Spacer(),
            if (hasLocation)
              GestureDetector(
                onTap: _clearLocation,
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Coordinates chip (when set)
        if (hasLocation)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location,
                    color: Color(0xFF9C27B0), size: 14),
                const SizedBox(width: 8),
                Text(
                  '${_latitude!.toStringAsFixed(5)},  ${_longitude!.toStringAsFixed(5)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                const Spacer(),
                const Text('Set ✓',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

        // Empty state
        if (!hasLocation)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.grey, size: 14),
                SizedBox(width: 8),
                Text('No location set yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // Two action buttons side by side
        Row(
          children: [
            Expanded(
              child: _locationButton(
                icon: _locationLoading ? null : Icons.gps_fixed,
                label: _locationLoading ? 'Detecting...' : 'Current Location',
                onTap: _locationLoading ? null : _getCurrentLocation,
                isPrimary: true,
                isLoading: _locationLoading,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _locationButton(
                icon: Icons.map_outlined,
                label: 'Pick on Map',
                onTap: _pickOnMap,
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _locationButton({
    IconData? icon,
    required String label,
    VoidCallback? onTap,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF9C27B0)
              : const Color(0xFF9C27B0).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color:
                      const Color(0xFF9C27B0).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      isPrimary ? Colors.white : const Color(0xFF9C27B0),
                ),
              )
            else if (icon != null)
              Icon(icon,
                  size: 16,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFF9C27B0)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : const Color(0xFF9C27B0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF9C27B0))),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text('Account',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Logout',
                  middleText: 'Are you sure you want to logout?',
                  textConfirm: 'Logout',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    Get.back();
                    Get.offAllNamed('/login');
                  },
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
              label: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
