import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/brand_controller.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  final BrandController controller = Get.find<BrandController>();
  bool _isGrid = false;
  int _currentPage = 0;
  static const int _pageSize = 10;

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
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
                }
                if (controller.programs.isEmpty) {
                  return const Center(child: Text('No programs yet', style: TextStyle(color: Colors.grey)));
                }

                final all = controller.programs.cast<Map>().toList();
                final totalPages = (all.length / _pageSize).ceil();
                final start = _currentPage * _pageSize;
                final end = (start + _pageSize).clamp(0, all.length);
                final paged = all.sublist(start, end);
                final showPagination = all.length > _pageSize;

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.fetchPrograms(refresh: true),
                        child: _isGrid
                            ? GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: paged.length,
                                itemBuilder: (ctx, i) =>
                                    _buildProgramCardGrid(ctx, paged[i]),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: paged.length,
                                itemBuilder: (ctx, i) =>
                                    _buildProgramCard(ctx, paged[i], controller),
                              ),
                      ),
                    ),
                    if (showPagination)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              icon: const Icon(Icons.chevron_left, size: 18),
                              label: const Text('Prev'),
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF2196F3)),
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $totalPages',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            TextButton.icon(
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              icon: const Icon(Icons.chevron_right, size: 18),
                              label: const Text('Next'),
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF2196F3)),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ProgramFormPage()),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Program', style: TextStyle(color: Colors.white)),
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
          const Expanded(
            child: Text('Programs',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _isGrid = !_isGrid;
              _currentPage = 0;
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isGrid ? Icons.view_list : Icons.grid_view,
                color: const Color(0xFF2196F3),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final photoUrl =
                (controller.userProfile['user']?['profile_photo'] ?? '')
                    .toString();
            final name = (controller.userProfile['profile']?['company_name'] ??
                    controller.dashboardData['user']?['name'] ??
                    'B')
                .toString();
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';
            return GestureDetector(
              onTap: () => controller.changePage(7),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Text(initial,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2196F3)))))
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3)))),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgramCardGrid(BuildContext context, Map program) {
    final isActive =
        program['is_active'] == true && program['is_published'] == true;
    final products = (program['products'] as List? ?? []);
    return GestureDetector(
      onTap: () => Get.to(() =>
          ProgramFormPage(existingProgram: Map<String, dynamic>.from(program))),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(program['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Off',
                    style: TextStyle(
                        fontSize: 9,
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(program['description'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (products.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: products.take(3).map((p) {
                  final name = p is Map
                      ? (p['product_name'] ?? 'Product')
                      : p.toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(name,
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF2196F3))),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.card_giftcard,
                      size: 12, color: Color(0xFF2196F3)),
                  const SizedBox(width: 2),
                  Text(
                    program['incentive_amount'] != null
                        ? 'Rs ${program['incentive_amount']}'
                        : '-',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2196F3)),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.people, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text('${program['enrolled_count'] ?? 0}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Map program, BrandController controller) {
    final isActive = program['is_active'] == true && program['is_published'] == true;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(program['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF4CAF50) : Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(program['description'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          if (program['products'] != null && (program['products'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final product in program['products'] as List)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product is Map ? (product['product_name'] ?? 'Product') : product.toString(),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2196F3), fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.card_giftcard, size: 16, color: Color(0xFF2196F3)),
              const SizedBox(width: 4),
              Text(
                program['incentive_amount'] != null ? 'Rs ${program['incentive_amount']}' : 'No incentive',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2196F3)),
              ),
              const Spacer(),
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${program['enrolled_count'] ?? 0} enrolled', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => Get.to(() => ProgramFormPage(existingProgram: Map<String, dynamic>.from(program))),
                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2196F3)),
                label: const Text('Edit', style: TextStyle(color: Color(0xFF2196F3), fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Program'),
                      content: const Text('Are you sure you want to delete this program?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    controller.deleteProgram(program['id'] as int);
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Unified form for Create & Edit program
class ProgramFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingProgram;

  const ProgramFormPage({super.key, this.existingProgram});

  bool get isEditing => existingProgram != null;

  @override
  State<ProgramFormPage> createState() => _ProgramFormPageState();
}

class _ProgramFormPageState extends State<ProgramFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _maxEnrollmentsController = TextEditingController();
  String? _startDate;
  String? _endDate;
  bool _isSubmitting = false;
  List<int> _selectedProducts = [];

  final controller = Get.find<BrandController>();

  @override
  void initState() {
    super.initState();
    if (controller.products.isEmpty) {
      controller.fetchProducts(refresh: true);
    }
    // Pre-fill if editing
    final p = widget.existingProgram;
    if (p != null) {
      _titleController.text = p['title'] ?? '';
      _descriptionController.text = p['description'] ?? '';
      _amountController.text = p['incentive_amount']?.toString() ?? '';
      _maxEnrollmentsController.text = p['max_enrollments']?.toString() ?? '';
      _startDate = p['start_date'] != null ? p['start_date'].toString().split('T').first : null;
      _endDate = p['end_date'] != null ? p['end_date'].toString().split('T').first : null;
      // Pre-select products
      if (p['products'] is List) {
        _selectedProducts = (p['products'] as List)
            .map((prod) => prod is Map ? (prod['id'] as int? ?? 0) : 0)
            .where((id) => id != 0)
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _maxEnrollmentsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate != null ? DateTime.tryParse(_startDate!) ?? DateTime.now() : DateTime.now())
        : (_endDate != null ? DateTime.tryParse(_endDate!) ?? DateTime.now() : DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) _startDate = formatted;
        else _endDate = formatted;
      });
    }
  }

  void _openProductPicker(List<Map> products) {
    // Work on a temp copy so Cancel truly cancels
    final temp = List<int>.from(_selectedProducts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.85,
            minChildSize: 0.4,
            builder: (_, scrollCtrl) => Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Products',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${temp.length} selected',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2196F3)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Product list
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final product = products[i];
                      final id = product['id'] as int;
                      final name = product['product_name']?.toString() ?? '';
                      final series = product['product_series']?.toString() ?? '';
                      final isChecked = temp.contains(id);
                      return CheckboxListTile(
                        value: isChecked,
                        onChanged: (checked) {
                          setModal(() {
                            if (checked == true) {
                              temp.add(id);
                            } else {
                              temp.remove(id);
                            }
                          });
                        },
                        title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: series.isNotEmpty ? Text(series, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
                        activeColor: const Color(0xFF2196F3),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                // Done button
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedProducts = temp);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                          child: Text(
                            'Done (${temp.length})',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program title is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };
    if (_amountController.text.isNotEmpty) data['incentive_amount'] = _amountController.text.trim();
    if (_startDate != null) data['start_date'] = _startDate;
    if (_endDate != null) data['end_date'] = _endDate;
    if (_maxEnrollmentsController.text.isNotEmpty) data['max_enrollments'] = _maxEnrollmentsController.text.trim();
    if (_selectedProducts.isNotEmpty) data['products'] = _selectedProducts;

    if (widget.isEditing) {
      final id = (widget.existingProgram!['id'] as num).toInt();
      await controller.updateProgram(id, data);
    } else {
      await controller.createProgram(data);
    }

    // Navigation is handled by the controller on success.
    // Only reset loading if still mounted (error case — form stays open).
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.isEditing ? 'Edit Program' : 'New Program',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Program Title *', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(controller: _titleController, decoration: _inputDecoration('e.g. Summer Installer Incentive 2025')),
                      const SizedBox(height: 16),
                      const Text('Description *', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(controller: _descriptionController, maxLines: 3, decoration: _inputDecoration('Describe the program...')),
                      const SizedBox(height: 16),
                      const Text('Incentive Amount (PKR)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: _inputDecoration('e.g. 5000')),
                      const SizedBox(height: 16),
                      const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickDate(isStart: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: Text(_startDate ?? 'Select start date', style: TextStyle(color: _startDate == null ? Colors.grey : Colors.black87))),
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('End Date', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickDate(isStart: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: Text(_endDate ?? 'Select end date', style: TextStyle(color: _endDate == null ? Colors.grey : Colors.black87))),
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Max Enrollments (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(controller: _maxEnrollmentsController, keyboardType: TextInputType.number, decoration: _inputDecoration('Leave blank for unlimited')),
                      const SizedBox(height: 20),
                      const Text('Products *', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Obx(() {
                        final products = controller.products;
                        if (products.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('No products available', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          );
                        }

                        // Build label for the dropdown trigger
                        final selectedNames = _selectedProducts
                            .map((id) {
                              final match = products.firstWhereOrNull((p) => p['id'] == id);
                              return match != null ? (match['product_name'] ?? '') : '';
                            })
                            .where((n) => n.isNotEmpty)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dropdown trigger
                            GestureDetector(
                              onTap: () => _openProductPicker(products.cast<Map>()),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedProducts.isEmpty ? Colors.transparent : const Color(0xFF2196F3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _selectedProducts.isEmpty
                                            ? 'Tap to select products...'
                                            : '${_selectedProducts.length} product${_selectedProducts.length > 1 ? 's' : ''} selected',
                                        style: TextStyle(
                                          color: _selectedProducts.isEmpty ? Colors.grey : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            // Selected product chips
                            if (selectedNames.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: selectedNames.map((name) {
                                  final id = _selectedProducts[selectedNames.indexOf(name)];
                                  return Chip(
                                    label: Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3))),
                                    backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                    side: const BorderSide(color: Color(0xFF2196F3), width: 0.5),
                                    deleteIconColor: const Color(0xFF2196F3),
                                    onDeleted: () => setState(() => _selectedProducts.remove(id)),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      widget.isEditing ? 'Save Changes' : 'Create Program',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
