import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'controllers/installer_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kBrand = Color(0xFFFF8F00);
const _kBg = Color(0xFFF5F5F5);

const _kAvatarColors = <Color>[
  Color(0xFFFF8F00),
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFF6A1B9A),
  Color(0xFFAD1457),
  Color(0xFF00838F),
];

// ─────────────────────────────────────────────────────────────────────────────
// View mode enum
// ─────────────────────────────────────────────────────────────────────────────

enum _ViewMode { list, grid2, grid4 }

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class AvailableJobsPage extends StatefulWidget {
  const AvailableJobsPage({super.key});

  @override
  State<AvailableJobsPage> createState() => _AvailableJobsPageState();
}

class _AvailableJobsPageState extends State<AvailableJobsPage> {
  final InstallerController controller = Get.find<InstallerController>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  _ViewMode _viewMode = _ViewMode.list;
  Position? _currentPosition;

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (controller.jobs.isEmpty) controller.fetchJobs();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── location ───────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        if (mounted) setState(() => _currentPosition = pos);
      }
    } catch (_) {}
  }

  String _distanceText(dynamic lat, dynamic lon) {
    if (_currentPosition == null || lat == null || lon == null) return '';
    final latD = double.tryParse(lat.toString());
    final lonD = double.tryParse(lon.toString());
    if (latD == null || lonD == null || (latD == 0 && lonD == 0)) return '';
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latD,
      lonD,
    );
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  // ── filtering ──────────────────────────────────────────────────────────────

  List<Map> _filteredJobs(List jobs) {
    if (_searchQuery.isEmpty) return jobs.cast<Map>();
    final q = _searchQuery.toLowerCase();
    return jobs.cast<Map>().where((job) {
      final title = (job['title'] ?? '').toString().toLowerCase();
      final location = (job['location'] ?? '').toString().toLowerCase();
      final city = (job['city'] ?? '').toString().toLowerCase();
      final shopName =
          ((job['shopkeeper'] as Map?) ?? {})['name']?.toString().toLowerCase() ?? '';
      return title.contains(q) ||
          location.contains(q) ||
          city.contains(q) ||
          shopName.contains(q);
    }).toList();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildSearchBar(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Hamburger menu
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: _kBrand),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Available Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // View-mode toggles
          _ViewToggleButton(
            icon: Icons.view_list,
            active: _viewMode == _ViewMode.list,
            onTap: () => setState(() => _viewMode = _ViewMode.list),
          ),
          const SizedBox(width: 4),
          _ViewToggleButton(
            icon: Icons.grid_view,
            active: _viewMode == _ViewMode.grid2,
            onTap: () => setState(() => _viewMode = _ViewMode.grid2),
          ),
          const SizedBox(width: 4),
          _ViewToggleButton(
            icon: Icons.apps,
            active: _viewMode == _ViewMode.grid4,
            onTap: () => setState(() => _viewMode = _ViewMode.grid4),
          ),
        ],
      ),
    );
  }

  // ── search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search by title, city, shop...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBrand),
        ),
      ),
    );
  }

  // ── body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (controller.jobsLoading.value && controller.jobs.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _kBrand),
        );
      }

      final filtered = _filteredJobs(controller.jobs.toList());

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off_outlined,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No jobs available',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => controller.fetchJobs(refresh: true),
                icon: const Icon(Icons.refresh, color: _kBrand),
                label:
                    const Text('Refresh', style: TextStyle(color: _kBrand)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kBrand),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _kBrand,
        onRefresh: () => controller.fetchJobs(refresh: true),
        child: _buildJobsView(filtered),
      );
    });
  }

  Widget _buildJobsView(List<Map> jobs) {
    switch (_viewMode) {
      case _ViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: jobs.length,
          itemBuilder: (ctx, i) =>
              _ListCard(job: jobs[i], index: i, onView: _showDetail),
        );

      case _ViewMode.grid2:
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: jobs.length,
          itemBuilder: (ctx, i) =>
              _Grid2Card(job: jobs[i], index: i, onView: _showDetail),
        );

      case _ViewMode.grid4:
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: jobs.length,
          itemBuilder: (ctx, i) =>
              _Grid4Card(job: jobs[i], index: i, onView: _showDetail),
        );
    }
  }

  // ── detail bottom sheet ────────────────────────────────────────────────────

  void _showDetail(Map job) {
    final dist = _distanceText(job['latitude'], job['longitude']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobDetailSheet(
        job: job,
        distanceText: dist,
        onApply: () {
          final id = job['id'];
          if (id != null) {
            controller.acceptJob(int.parse(id.toString()));
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View-mode toggle button
// ─────────────────────────────────────────────────────────────────────────────

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? _kBrand.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? _kBrand : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(icon, size: 20, color: active ? _kBrand : Colors.grey),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar circle
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.letter,
    required this.color,
    this.radius = 22,
  });

  final String letter;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.82,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Urgent chip
// ─────────────────────────────────────────────────────────────────────────────

class _UrgentChip extends StatelessWidget {
  const _UrgentChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Text(
        'Urgent',
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIST MODE card
// ─────────────────────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.job,
    required this.index,
    required this.onView,
  });

  final Map job;
  final int index;
  final void Function(Map) onView;

  @override
  Widget build(BuildContext context) {
    final shopkeeper = (job['shopkeeper'] as Map?) ?? {};
    final shopName = shopkeeper['name']?.toString() ?? 'Unknown Shop';
    final title = job['title']?.toString() ?? 'Untitled';
    final city = job['city']?.toString() ?? '';
    final budget = job['budget'] != null ? 'Rs ${job['budget']}' : 'N/A';
    final isUrgent = job['is_urgent'] == true;
    final color = _kAvatarColors[index % _kAvatarColors.length];
    final initial = title.isNotEmpty ? title[0] : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            _AvatarCircle(letter: initial, color: color),
            const SizedBox(width: 12),

            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent) ...[
                        const SizedBox(width: 6),
                        const _UrgentChip(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    shopName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (city.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 2),
                        Text(
                          city,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right: budget + View button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  budget,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _kBrand,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => onView(job),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 30),
                    side: const BorderSide(color: _kBrand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                        color: _kBrand,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2-COLUMN GRID card
// ─────────────────────────────────────────────────────────────────────────────

class _Grid2Card extends StatelessWidget {
  const _Grid2Card({
    required this.job,
    required this.index,
    required this.onView,
  });

  final Map job;
  final int index;
  final void Function(Map) onView;

  @override
  Widget build(BuildContext context) {
    final shopkeeper = (job['shopkeeper'] as Map?) ?? {};
    final shopName = shopkeeper['name']?.toString() ?? 'Unknown Shop';
    final title = job['title']?.toString() ?? 'Untitled';
    final city = job['city']?.toString() ?? '';
    final budget = job['budget'] != null ? 'Rs ${job['budget']}' : 'N/A';
    final isUrgent = job['is_urgent'] == true;
    final color = _kAvatarColors[index % _kAvatarColors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header strip
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUrgent) ...[
                  const _UrgentChip(),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmallInfoRow(
                      icon: Icons.store, text: shopName, maxLines: 1),
                  const SizedBox(height: 4),
                  if (city.isNotEmpty) ...[
                    _SmallInfoRow(
                        icon: Icons.location_on, text: city, maxLines: 1),
                    const SizedBox(height: 4),
                  ],
                  _SmallInfoRow(
                    icon: Icons.attach_money,
                    text: budget,
                    textColor: _kBrand,
                    bold: true,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => onView(job),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: _kBrand),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                            color: _kBrand,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
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

// ─────────────────────────────────────────────────────────────────────────────
// 4-COLUMN GRID card (compact, tap anywhere)
// ─────────────────────────────────────────────────────────────────────────────

class _Grid4Card extends StatelessWidget {
  const _Grid4Card({
    required this.job,
    required this.index,
    required this.onView,
  });

  final Map job;
  final int index;
  final void Function(Map) onView;

  @override
  Widget build(BuildContext context) {
    final title = job['title']?.toString() ?? 'Untitled';
    final budget = job['budget'] != null ? 'Rs ${job['budget']}' : 'N/A';
    final city = job['city']?.toString() ?? '';
    final color = _kAvatarColors[index % _kAvatarColors.length];
    final initial = title.isNotEmpty ? title[0] : '?';
    final isUrgent = job['is_urgent'] == true;

    return GestureDetector(
      onTap: () => onView(job),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _AvatarCircle(letter: initial, color: color, radius: 18),
                  if (isUrgent)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              if (city.isNotEmpty) ...[
                Text(
                  city,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
              ],
              Text(
                budget,
                style: const TextStyle(
                  fontSize: 10,
                  color: _kBrand,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small info row (used inside grid cards)
// ─────────────────────────────────────────────────────────────────────────────

class _SmallInfoRow extends StatelessWidget {
  const _SmallInfoRow({
    required this.icon,
    required this.text,
    this.textColor,
    this.bold = false,
    this.maxLines = 2,
  });

  final IconData icon;
  final String text;
  final Color? textColor;
  final bool bold;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: textColor ?? Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: textColor ?? Colors.grey.shade700,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _JobDetailSheet extends StatelessWidget {
  const _JobDetailSheet({
    required this.job,
    required this.distanceText,
    required this.onApply,
  });

  final Map job;
  final String distanceText;
  final VoidCallback onApply;

  String get _fullAddress {
    final parts = <String>[
      if ((job['location'] ?? '').toString().isNotEmpty)
        job['location'].toString(),
      if ((job['city'] ?? '').toString().isNotEmpty) job['city'].toString(),
      if ((job['region'] ?? '').toString().isNotEmpty)
        job['region'].toString(),
    ];
    return parts.join(', ');
  }

  String get _skills {
    final s = job['skills_required'];
    if (s == null) return 'Not specified';
    if (s is List) return s.join(', ');
    return s.toString();
  }

  String get _deadline {
    final d = job['deadline'];
    if (d == null || d.toString().isEmpty) return 'Not specified';
    return d.toString();
  }

  @override
  Widget build(BuildContext context) {
    final shopkeeper = (job['shopkeeper'] as Map?) ?? {};
    final shopName = shopkeeper['name']?.toString() ?? 'Unknown Shop';
    final shopPhone = shopkeeper['phone']?.toString() ?? '';
    final title = job['title']?.toString() ?? 'Untitled';
    final description = job['description']?.toString() ?? '';
    final budget =
        job['budget'] != null ? 'Rs ${job['budget']}' : 'Not specified';
    final isUrgent = job['is_urgent'] == true;
    final status = job['status']?.toString() ?? 'open';
    final assignedCount = job['assigned_count']?.toString() ?? '0';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    // Title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          const _UrgentChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status + assigned count
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kBrand.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: _kBrand,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$assignedCount assigned',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Description
                    if (description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Detail rows
                    _DetailRow(
                      icon: Icons.store,
                      label: 'Shop',
                      value: shopPhone.isNotEmpty
                          ? '$shopName  ·  $shopPhone'
                          : shopName,
                    ),
                    _DetailRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: _fullAddress.isNotEmpty
                          ? _fullAddress
                          : 'Not specified',
                    ),
                    if (distanceText.isNotEmpty)
                      _DetailRow(
                        icon: Icons.near_me,
                        label: 'Distance',
                        value: distanceText,
                        valueColor: _kBrand,
                      ),
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: 'Budget',
                      value: budget,
                      valueColor: _kBrand,
                      bold: true,
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Deadline',
                      value: _deadline,
                    ),
                    _DetailRow(
                      icon: Icons.build,
                      label: 'Skills Required',
                      value: _skills,
                    ),
                    _DetailRow(
                      icon: Icons.bar_chart,
                      label: 'Status',
                      value: status.isNotEmpty
                          ? '${status[0].toUpperCase()}${status.substring(1)}'
                              '  —  $assignedCount assigned'
                          : '$assignedCount assigned',
                    ),
                  ],
                ),
              ),

              // Pinned Apply button
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply for this Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row widget (used in bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kBrand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kBrand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: valueColor ?? Colors.black87,
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
