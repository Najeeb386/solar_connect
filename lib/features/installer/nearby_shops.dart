import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'controllers/installer_controller.dart';

class NearbyShopsPage extends StatefulWidget {
  const NearbyShopsPage({super.key});

  @override
  State<NearbyShopsPage> createState() => _NearbyShopsPageState();
}

class _NearbyShopsPageState extends State<NearbyShopsPage> {
  final _searchController = TextEditingController();
  final _mapController = MapController();

  String _searchQuery = '';
  bool _showMap = false;
  Position? _myPosition;
  Map? _selectedShop; // shop tapped on map

  bool _hasFitMap = false; // fit map only once on first open

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── location ─────────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        if (mounted) {
          setState(() => _myPosition = pos);
          // Re-fetch shops with actual GPS coordinates so distance is calculated
          final controller = Get.find<InstallerController>();
          await controller.fetchNearbyShops(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
          // If map is already open, fit to markers now
          if (_showMap && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitMapToMarkers(controller.nearbyShops.toList());
            });
          }
        }
      }
    } catch (_) {}
  }

  /// Fit the map camera to include the installer + all shop markers.
  void _fitMapToMarkers(List shops) {
    final points = <LatLng>[];
    if (_myPosition != null) {
      points.add(LatLng(_myPosition!.latitude, _myPosition!.longitude));
    }
    for (final shop in shops) {
      final lat = double.tryParse(shop['latitude']?.toString() ?? '');
      final lng = double.tryParse(shop['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        points.add(LatLng(lat, lng));
      }
    }
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 14.0);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    // If all points are very close (< ~500m bounding box), just center + zoom in
    final latSpan = (bounds.north - bounds.south).abs();
    final lngSpan = (bounds.east - bounds.west).abs();
    if (latSpan < 0.005 && lngSpan < 0.005) {
      // All markers within ~500m — center on mid-point, zoom to street level
      _mapController.move(bounds.center, 15.0);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(70)),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  List<Map> _filtered(List shops) {
    if (_searchQuery.isEmpty) return shops.cast<Map>();
    final q = _searchQuery.toLowerCase();
    return shops.cast<Map>().where((s) {
      final name = (s['shop_name'] ?? s['name'] ?? '').toString().toLowerCase();
      final city = (s['city'] ?? '').toString().toLowerCase();
      return name.contains(q) || city.contains(q);
    }).toList();
  }

  // Default center: Pakistan (Lahore) when no GPS
  LatLng get _defaultCenter => _myPosition != null
      ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
      : const LatLng(31.5204, 74.3587);

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            if (!_showMap)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildSearchBar(),
              ),
            Expanded(
              child: Obx(() {
                if (controller.shopsLoading.value && controller.nearbyShops.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8F00)),
                  );
                }

                final filtered = _filtered(controller.nearbyShops.toList());

                if (filtered.isEmpty && !_showMap) {
                  return _buildEmpty(controller);
                }

                return _showMap
                    ? _buildMap(filtered, controller)
                    : _buildList(filtered, controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, InstallerController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Menu
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nearby Shops',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          // Map / List toggle
          Obx(() {
            final loading = controller.shopsLoading.value;
            return Row(
              children: [
                if (loading)
                  const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFFF8F00)),
                    onPressed: () => controller.fetchNearbyShops(
                      latitude: _myPosition?.latitude,
                      longitude: _myPosition?.longitude,
                    ),
                    tooltip: 'Refresh',
                  ),
                const SizedBox(width: 4),
                // Map icon toggle button
                GestureDetector(
                  onTap: () {
                    final wasMap = _showMap;
                    setState(() {
                      _showMap = !_showMap;
                      _selectedShop = null;
                      if (!wasMap) _hasFitMap = false; // reset so we fit on open
                    });
                    // Fit map to all markers when first switching to map view
                    if (!wasMap) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_hasFitMap) {
                          _hasFitMap = true;
                          final ctrl = Get.find<InstallerController>();
                          _fitMapToMarkers(ctrl.nearbyShops.toList());
                        }
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: _showMap
                          ? const Color(0xFFFF8F00)
                          : const Color(0xFFFF8F00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _showMap ? Icons.list : Icons.map_outlined,
                      color: _showMap ? Colors.white : const Color(0xFFFF8F00),
                      size: 22,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── search bar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: 'Search shops by name or city...',
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8F00)),
        ),
      ),
    );
  }

  // ── empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmpty(InstallerController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            controller.nearbyShops.isEmpty
                ? 'No nearby shops found.\nShops will appear here once registered.'
                : 'No shops match your search.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          if (controller.nearbyShops.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.fetchNearbyShops(
                latitude: _myPosition?.latitude,
                longitude: _myPosition?.longitude,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8F00),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── LIST VIEW ────────────────────────────────────────────────────────────────

  Widget _buildList(List<Map> shops, InstallerController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchNearbyShops(
        latitude: _myPosition?.latitude,
        longitude: _myPosition?.longitude,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: shops.length,
        itemBuilder: (context, index) => _buildShopCard(shops[index]),
      ),
    );
  }

  Widget _buildShopCard(Map shop) {
    final name = shop['shop_name'] ?? shop['name'] ?? 'Shop';
    final city = shop['city'] ?? '';
    final region = shop['region'] ?? '';
    final address = shop['address'] ?? '';
    final distanceKm = shop['distance_km'];
    final activeJobs = shop['active_jobs_count'] ?? 0;
    final phone = shop['phone'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    final locationText = address.isNotEmpty
        ? address
        : [city, region].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(initial,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    if (locationText.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(locationText,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (distanceKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$distanceKm km',
                    style: const TextStyle(color: Color(0xFFFF8F00), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (phone.isNotEmpty) ...[
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(width: 16),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$activeJobs Active Jobs',
                  style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── MAP VIEW ─────────────────────────────────────────────────────────────────

  Widget _buildMap(List<Map> shops, InstallerController controller) {
    final markers = <Marker>[];

    // ── Installer's current location marker ──────────────────────────────────
    if (_myPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_myPosition!.latitude, _myPosition!.longitude),
          width: 80,
          height: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                  ],
                ),
                child: const Text(
                  'You',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              // Pointer
              CustomPaint(size: const Size(10, 6), painter: _TrianglePainter(const Color(0xFF1565C0))),
              // Dot
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Shop markers ─────────────────────────────────────────────────────────
    for (final shop in shops) {
      final lat = double.tryParse(shop['latitude']?.toString() ?? '');
      final lng = double.tryParse(shop['longitude']?.toString() ?? '');
      if (lat == null || lng == null) continue;

      final name = (shop['shop_name'] ?? shop['name'] ?? 'Shop').toString();
      final isSelected = _selectedShop != null && _selectedShop!['shop_id'] == shop['shop_id'];
      final shortName = name.length > 14 ? '${name.substring(0, 13)}…' : name;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 100,
          height: 68,
          child: GestureDetector(
            onTap: () => setState(() => _selectedShop = isSelected ? null : shop),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE65100) : const Color(0xFFFF8F00),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    shortName,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CustomPaint(
                  size: const Size(10, 6),
                  painter: _TrianglePainter(isSelected ? const Color(0xFFE65100) : const Color(0xFFFF8F00)),
                ),
                // Pin icon
                Icon(
                  Icons.location_pin,
                  color: isSelected ? const Color(0xFFE65100) : const Color(0xFFFF8F00),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // ── Flutter Map ───────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 12.0,
            minZoom: 3,
            maxZoom: 19,
            onTap: (tapPos, latLng) => setState(() => _selectedShop = null),
            // Allow pinch-zoom to win gesture arena immediately,
            // preventing conflicts with marker GestureDetectors
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.solarpartner.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // ── Right-side controls ───────────────────────────────────────────────
        Positioned(
          bottom: _selectedShop != null ? 190 : 20,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom in
              _mapBtn('zoom_in', Icons.add, () {
                _mapController.move(_mapController.camera.center,
                    _mapController.camera.zoom + 1);
              }),
              const SizedBox(height: 6),
              // Zoom out
              _mapBtn('zoom_out', Icons.remove, () {
                _mapController.move(_mapController.camera.center,
                    _mapController.camera.zoom - 1);
              }),
              const SizedBox(height: 10),
              // Fit all markers
              _mapBtn('fit_all', Icons.fit_screen, () {
                final ctrl = Get.find<InstallerController>();
                _fitMapToMarkers(ctrl.nearbyShops.toList());
              }),
              const SizedBox(height: 6),
              // My location
              _mapBtn('locate_me', Icons.my_location, () {
                if (_myPosition != null) {
                  _mapController.move(
                      LatLng(_myPosition!.latitude, _myPosition!.longitude), 14.0);
                } else {
                  _getCurrentLocation();
                }
              }),
            ],
          ),
        ),

        // ── Shop count badge ──────────────────────────────────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store, size: 14, color: Color(0xFFFF8F00)),
                const SizedBox(width: 5),
                Text(
                  '${shops.length} shop${shops.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),

        // ── Selected shop info card ───────────────────────────────────────────
        if (_selectedShop != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildShopInfoCard(_selectedShop!),
          ),
      ],
    );
  }

  // ── Map control button helper ─────────────────────────────────────────────

  Widget _mapBtn(String tag, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 38, height: 38,
          child: Icon(icon, color: const Color(0xFFFF8F00), size: 20),
        ),
      ),
    );
  }

  // ── Map shop info card (shown on tap) ─────────────────────────────────────

  Widget _buildShopInfoCard(Map shop) {
    final name = shop['shop_name'] ?? shop['name'] ?? 'Shop';
    final city = shop['city'] ?? '';
    final region = shop['region'] ?? '';
    final address = shop['address'] ?? '';
    final distanceKm = shop['distance_km'];
    final activeJobs = shop['active_jobs_count'] ?? 0;
    final phone = shop['phone'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    final locationText = address.isNotEmpty
        ? address
        : [city, region].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(initial,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    if (locationText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(locationText,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
              if (distanceKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$distanceKm km',
                    style: const TextStyle(
                      color: Color(0xFFFF8F00), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (phone.isNotEmpty) ...[
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(),
              ] else
                const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeJobs Active Job${activeJobs == 1 ? '' : 's'}',
                  style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Triangle painter — the small downward pointer below a label bubble
// ─────────────────────────────────────────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
