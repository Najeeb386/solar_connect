import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/widgets/storage_image.dart';
import 'controllers/brand_controller.dart';

// ─── View mode enum ──────────────────────────────────────────────────────────
enum _ViewMode { grid2, grid4, list }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final controller = Get.find<BrandController>();

  // Form controllers
  final _nameController = TextEditingController();
  final _seriesController = TextEditingController();
  final _descController = TextEditingController();
  int? _editingProductId;

  // View state
  _ViewMode _viewMode = _ViewMode.grid2;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  static const _brandColor = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    controller.fetchProducts(refresh: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seriesController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Product form bottom sheet ────────────────────────────────────────────

  void _showProductForm({Map<String, dynamic>? product}) {
    _editingProductId = product?['id'];
    _nameController.text = product?['product_name'] ?? '';
    _seriesController.text = product?['product_series'] ?? '';
    _descController.text = product?['description'] ?? '';

    // Local to bottom sheet — avoids parent state timing issues
    XFile? pickedFile;
    Uint8List? pickedBytes;

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _editingProductId == null ? 'Add New Product' : 'Edit Product',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Image picker
                GestureDetector(
                  onTap: () async {
                    final XFile? img = await ImagePicker()
                        .pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (img != null) {
                      final bytes = await img.readAsBytes();
                      setSheet(() {
                        pickedFile = img;
                        pickedBytes = bytes;
                      });
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: pickedBytes != null
                          ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                          : (product?['photo'] != null
                              ? StorageImage(url: product!['photo'], fit: BoxFit.cover)
                              : const _PlaceholderIcon()),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Tap to ${pickedBytes != null ? "change" : "add"} image',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 20),

                _formField(_nameController, 'Product Name *', Icons.inventory_2_outlined),
                const SizedBox(height: 12),
                _formField(_seriesController, 'Product Series', Icons.label_outline),
                const SizedBox(height: 12),
                _formField(_descController, 'Description', Icons.notes,
                    maxLines: 3),
                const SizedBox(height: 20),

                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Product name is required',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        if (_editingProductId != null) {
                          // Show confirmation for edit
                          final confirm = await Get.dialog<bool>(AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Save Changes'),
                            content: const Text(
                                'Are you sure you want to save these changes?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Save',
                                    style: TextStyle(color: _brandColor)),
                              ),
                            ],
                          ));
                          if (confirm != true) return;
                        }
                        bool success = false;
                        if (_editingProductId == null) {
                          success = await controller.createProduct(
                            _nameController.text.trim(),
                            _seriesController.text.trim(),
                            _descController.text.trim(),
                            pickedFile,
                          );
                        } else {
                          success = await controller.updateProduct(
                            _editingProductId!,
                            _nameController.text.trim(),
                            _seriesController.text.trim(),
                            _descController.text.trim(),
                            pickedFile,
                          );
                        }
                        if (success) Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _editingProductId == null ? 'Add Product' : 'Save Changes',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }

  TextField _formField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _brandColor)),
      ),
    );
  }

  // ─── QR Code sheet ───────────────────────────────────────────────────────

  String _buildQRData(Map<String, dynamic> product) {
    final profile = controller.userProfile;
    final brandName = profile['company_name'] ?? profile['name'] ?? '';
    final brandId = profile['user_id'] ?? profile['id'] ?? 0;
    return jsonEncode({
      'app': 'solar',
      'pid': product['id'],
      'pname': product['product_name'] ?? '',
      'series': product['product_series'] ?? '',
      'bid': brandId,
      'bname': brandName,
    });
  }

  void _showQRSheet(Map<String, dynamic> product) {
    final qrData = _buildQRData(product);
    final qrKey = GlobalKey();

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
                ),

                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _brandColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.qr_code_2,
                        color: _brandColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Product QR Code',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // QR Code
                RepaintBoundary(
                  key: qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 220,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1565C0),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product['product_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if ((product['product_series'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product['product_series'] ?? '',
                            style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Product info chip row
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _infoBadge(Icons.tag, 'ID: ${product['id']}'),
                    if ((product['product_name'] ?? '').isNotEmpty)
                      _infoBadge(Icons.inventory_2_outlined,
                        product['product_name']),
                    if ((product['product_series'] ?? '').isNotEmpty)
                      _infoBadge(Icons.label_outline,
                        product['product_series']),
                  ],
                ),
                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _brandColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: _brandColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Print or display this QR code on your product packaging. '
                          'Installers scan it to automatically identify the product and submit a reward claim.',
                          style: TextStyle(fontSize: 12, color: _brandColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Save as image button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveQRImage(qrKey, product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white, size: 18),
                    label: const Text('Save QR Image',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _saveQRImage(GlobalKey key, Map<String, dynamic> product) async {
    try {
      final boundary = key.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      // Bytes captured — in a real device you'd save via path_provider
      // For now notify user to screenshot
      Get.snackbar(
        'QR Ready',
        'Screenshot this QR code or print it for your product.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      Get.snackbar('Tip', 'Take a screenshot to save this QR code.',
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget _infoBadge(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _brandColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _brandColor.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _brandColor),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: _brandColor)),
      ],
    ),
  );

  // ─── Delete confirm ───────────────────────────────────────────────────────

  void _showDeleteConfirm(int productId) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Product'),
      content: const Text('Are you sure you want to delete this product?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteProduct(productId);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          _buildToolbar(),
          Expanded(
            child: Obx(() {
              if (controller.productsLoading.value &&
                  controller.products.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: _brandColor));
              }

              final filtered = controller.products.where((p) {
                final prod = p as Map;
                return _searchQuery.isEmpty ||
                    (prod['product_name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    (prod['product_series'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
              }).toList();

              if (filtered.isEmpty) return _buildEmpty();

              return RefreshIndicator(
                color: _brandColor,
                onRefresh: () => controller.fetchProducts(refresh: true),
                child: _viewMode == _ViewMode.list
                    ? _buildListView(filtered)
                    : _buildGridView(filtered),
              );
            }),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        backgroundColor: _brandColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: Colors.white,
      child: Row(children: [
        // Back button — page is a tab, navigate to dashboard home (index 0)
        GestureDetector(
          onTap: () => controller.changePage(0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: _brandColor, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Products',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Obx(() => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _brandColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.products.length} items',
                style: const TextStyle(
                    fontSize: 12,
                    color: _brandColor,
                    fontWeight: FontWeight.w600),
              ),
            )),
      ]),
    );
  }

  // ─── Toolbar: search + view switcher ─────────────────────────────────────

  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(children: [
        // Search bar
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(fontSize: 13),
            prefixIcon:
                const Icon(Icons.search, color: Colors.grey, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),

        // View mode switcher
        Row(children: [
          const Text('View:',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          _viewBtn(_ViewMode.grid2, Icons.grid_view, '2×'),
          const SizedBox(width: 6),
          _viewBtn(_ViewMode.grid4, Icons.apps, '4×'),
          const SizedBox(width: 6),
          _viewBtn(_ViewMode.list, Icons.view_list, 'List'),
        ]),
      ]),
    );
  }

  Widget _viewBtn(_ViewMode mode, IconData icon, String label) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _brandColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? _brandColor : Colors.grey.shade300),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey.shade700)),
        ]),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isEmpty ? 'No products yet' : 'No results for "$_searchQuery"',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
        ),
        if (_searchQuery.isEmpty) ...[
          const SizedBox(height: 8),
          Text('Tap + Add Product to get started',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ]),
    );
  }

  // ─── Grid view (2 or 4 columns) ───────────────────────────────────────────

  Widget _buildGridView(List filtered) {
    final cols = _viewMode == _ViewMode.grid4 ? 4 : 2;
    final ratio = cols == 4 ? 0.58 : 0.68;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: ratio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filtered.length,
      itemBuilder: (_, i) =>
          _buildGridCard(filtered[i] as Map<String, dynamic>, compact: cols == 4),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> product,
      {bool compact = false}) {
    final imgH = compact ? 80.0 : 130.0;
    final titleSize = compact ? 10.0 : 13.0;
    final subSize = compact ? 9.0 : 11.0;

    return Card(
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: imgH,
            width: double.infinity,
            child: StorageImage(url: product['photo']),
          ),
        ),
        // Info
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(compact ? 6 : 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'] ?? '',
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: titleSize),
                  ),
                  if ((product['product_series'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product['product_series'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: subSize, color: Colors.grey.shade500),
                    ),
                  ],
                  const Spacer(),
                  Row(children: [
                    Expanded(
                      child: _smallBtn(
                        icon: Icons.qr_code_2,
                        color: Colors.purple,
                        onTap: () => _showQRSheet(product),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _smallBtn(
                        icon: Icons.edit_outlined,
                        color: _brandColor,
                        onTap: () =>
                            _showProductForm(product: product),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _smallBtn(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () =>
                            _showDeleteConfirm(product['id']),
                      ),
                    ),
                  ]),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _smallBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  // ─── List view ────────────────────────────────────────────────────────────

  Widget _buildListView(List filtered) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _buildListCard(filtered[i] as Map<String, dynamic>),
    );
  }

  Widget _buildListCard(Map<String, dynamic> product) {
    return Card(
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: StorageImage(url: product['photo']),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if ((product['product_series'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      product['product_series'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                  if ((product['description'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ]),
          ),
          const SizedBox(width: 8),
          // Actions column
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _iconAction(
                icon: Icons.qr_code_2,
                color: Colors.purple,
                onTap: () => _showQRSheet(product)),
            const SizedBox(height: 6),
            _iconAction(
                icon: Icons.edit_outlined,
                color: _brandColor,
                onTap: () => _showProductForm(product: product)),
            const SizedBox(height: 6),
            _iconAction(
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => _showDeleteConfirm(product['id'])),
          ]),
        ]),
      ),
    );
  }

  Widget _iconAction(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

}

// ─── Shared placeholder ───────────────────────────────────────────────────────

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.inventory_2_outlined,
            size: 28, color: Colors.grey.shade400),
      ),
    );
  }
}
