import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/installer_controller.dart';

class InstallerProgramPage extends StatefulWidget {
  const InstallerProgramPage({super.key});

  @override
  State<InstallerProgramPage> createState() => _InstallerProgramPageState();
}

class _InstallerProgramPageState extends State<InstallerProgramPage> {
  final InstallerController controller = Get.find<InstallerController>();

  String _brandSearch = '';
  String? _selectedBrand; // null = all brands
  bool _isGrid = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> _getBrands(List programs) {
    final brands = <String>{};
    for (final p in programs) {
      final name = (p as Map)['brand']?['name']?.toString() ?? '';
      if (name.isNotEmpty) brands.add(name);
    }
    final list = brands.toList()..sort();
    return list;
  }

  List _filteredPrograms(List programs) {
    return programs.where((p) {
      final brandName = (p as Map)['brand']?['name']?.toString() ?? '';
      final matchesBrand = _selectedBrand == null || brandName == _selectedBrand;
      final matchesSearch = _brandSearch.isEmpty ||
          brandName.toLowerCase().contains(_brandSearch.toLowerCase()) ||
          (p['title']?.toString() ?? '').toLowerCase().contains(_brandSearch.toLowerCase());
      return matchesBrand && matchesSearch;
    }).toList();
  }

  List _paginated(List all) {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.programsLoading.value && controller.programs.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8F00)));
                }
                final allBrands = _getBrands(controller.programs.toList());
                final filtered = _filteredPrograms(controller.programs.toList());
                final paged = _paginated(filtered);
                final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _currentPage = 0);
                    await controller.fetchPrograms(refresh: true);
                  },
                  child: Column(
                    children: [
                      // ── Brand search + filter chips ──
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchCtrl,
                              onChanged: (v) => setState(() { _brandSearch = v; _currentPage = 0; }),
                              decoration: InputDecoration(
                                hintText: 'Search brand or program...',
                                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                suffixIcon: _brandSearch.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          setState(() { _brandSearch = ''; _currentPage = 0; });
                                        })
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            if (allBrands.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 34,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _brandChip('All', null),
                                    ...allBrands.map((b) => _brandChip(b, b)),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      // ── Stats + grid/list toggle ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            Obx(() {
                              final enrolled = controller.programs
                                  .where((p) => p['is_enrolled'] == true).length;
                              return Text(
                                '${filtered.length} program${filtered.length == 1 ? '' : 's'} · $enrolled enrolled',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              );
                            }),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() { _isGrid = !_isGrid; _currentPage = 0; }),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isGrid ? Icons.view_list : Icons.grid_view,
                                  color: const Color(0xFFFF8F00), size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── Program list/grid ──
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmpty()
                            : _isGrid
                                ? _buildGrid(paged)
                                : _buildListView(paged),
                      ),
                      // ── Pagination ──
                      if (filtered.length > _pageSize)
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                label: const Text('Prev'),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF8F00)),
                              ),
                              Text('${_currentPage + 1} / $totalPages',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              TextButton.icon(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                label: const Text('Next'),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF8F00)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandChip(String label, String? value) {
    final selected = _selectedBrand == value;
    return GestureDetector(
      onTap: () => setState(() { _selectedBrand = value; _currentPage = 0; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF8F00) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey[700],
            )),
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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: Color(0xFFFF8F00)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Brand Programs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Obx(() => controller.programsLoading.value
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFFF8F00)),
                  onPressed: () => controller.fetchPrograms(refresh: true))),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _brandSearch.isNotEmpty || _selectedBrand != null
                ? 'No programs match filter.'
                : 'No programs available yet.\nBrands will post programs here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List programs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: programs.length,
      itemBuilder: (_, i) => _buildProgramCard(programs[i]),
    );
  }

  Widget _buildGrid(List programs) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: programs.length,
      itemBuilder: (_, i) => _buildProgramCardGrid(programs[i]),
    );
  }

  // ── List card ──────────────────────────────────────────────────────────────

  Widget _buildProgramCard(dynamic program) {
    final title       = program['title']?.toString() ?? 'Program';
    final description = program['description']?.toString() ?? '';
    final brandName   = program['brand']?['name']?.toString() ?? 'Brand';
    final incentive   = program['incentive_amount']?.toString() ?? '0';
    final programId   = program['id'] as int?;
    final products    = (program['products'] as List?) ?? [];
    final allEnrolled = program['all_products_enrolled'] == true;
    final anyEnrolled = program['is_enrolled'] == true;
    final color       = _brandColor(brandName);
    final initial     = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _brandAvatar(initial, color, 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('by $brandName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if ((double.tryParse(incentive) ?? 0) > 0) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Rs ${double.parse(incentive).toStringAsFixed(0)} / claim',
                            style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          // Products inline
          if (products.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...products.map<Widget>((product) {
              final pId        = product['id'] as int?;
              final pName      = product['product_name']?.toString() ?? '';
              final pSeries    = product['product_series']?.toString() ?? '';
              final isEnrolled = product['is_enrolled'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.inventory_2_outlined, size: 16, color: color.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(pName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (pSeries.isNotEmpty)
                          Text(pSeries, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                    ),
                    isEnrolled
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.check_circle, size: 11, color: Color(0xFF4CAF50)),
                              SizedBox(width: 3),
                              Text('Enrolled', style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
                            ]))
                        : SizedBox(
                            height: 26,
                            child: ElevatedButton(
                              onPressed: programId != null && pId != null
                                  ? () => controller.enrollInProgram(programId, productId: pId)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Enroll', style: TextStyle(fontSize: 11)),
                            )),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${program['current_enrollments'] ?? 0} enrolled',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const Spacer(),
              if (anyEnrolled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: allEnrolled
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allEnrolled ? '✓ All enrolled' : '⚡ Partial',
                    style: TextStyle(
                      fontSize: 10,
                      color: allEnrolled ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Grid card ──────────────────────────────────────────────────────────────

  Widget _buildProgramCardGrid(dynamic program) {
    final title     = program['title']?.toString() ?? 'Program';
    final brandName = program['brand']?['name']?.toString() ?? 'Brand';
    final incentive = program['incentive_amount']?.toString() ?? '0';
    final programId = program['id'] as int?;
    final products  = (program['products'] as List?) ?? [];
    final anyEnrolled = program['is_enrolled'] == true;
    final color     = _brandColor(brandName);
    final initial   = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _brandAvatar(initial, color, 36),
              const SizedBox(width: 8),
              Expanded(
                child: Text(brandName,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (anyEnrolled)
                const Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          if ((double.tryParse(incentive) ?? 0) > 0) ...[
            const SizedBox(height: 4),
            Text('Rs ${double.parse(incentive).toStringAsFixed(0)}/claim',
                style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 4),
          // Products inline list
          ...products.take(3).map<Widget>((product) {
            final pId        = product['id'] as int?;
            final pName      = product['product_name']?.toString() ?? '';
            final isEnrolled = product['is_enrolled'] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(pName, style: const TextStyle(fontSize: 10, color: Colors.black87),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (isEnrolled)
                    const Icon(Icons.check_circle, size: 12, color: Color(0xFF4CAF50))
                  else if (programId != null && pId != null)
                    GestureDetector(
                      onTap: () => controller.enrollInProgram(programId, productId: pId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          }),
          if (products.length > 3)
            Text('+${products.length - 3} more',
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _brandAvatar(String initial, Color color, double size) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(size * 0.25)),
    child: Center(child: Text(initial, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: color))),
  );

  Color _brandColor(String brandName) {
    const colors = [
      Color(0xFF2196F3), Color(0xFFE91E63), Color(0xFF4CAF50),
      Color(0xFFFF5722), Color(0xFF9C27B0), Color(0xFF00BCD4),
      Color(0xFFFF9800), Color(0xFF795548),
    ];
    return brandName.isNotEmpty ? colors[brandName.codeUnitAt(0) % colors.length] : colors[0];
  }
}
