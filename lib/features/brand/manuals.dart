import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controllers/brand_controller.dart';

class ManualsPage extends StatefulWidget {
  const ManualsPage({super.key});

  @override
  State<ManualsPage> createState() => _ManualsPageState();
}

class _ManualsPageState extends State<ManualsPage> {
  bool _showUploadForm = false;
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showUploadForm)
              Expanded(child: _buildUploadForm(controller))
            else
              Expanded(child: _buildManualsList(controller)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showUploadForm = !_showUploadForm),
        backgroundColor: const Color(0xFF2196F3),
        icon: Icon(_showUploadForm ? Icons.list : Icons.upload_file, color: Colors.white),
        label: Text(_showUploadForm ? 'View Manuals' : 'Upload Manual', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final BrandController controller = Get.find<BrandController>();
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
            child: Text('Manuals',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
          Obx(() {
            final photoUrl =
                (controller.userProfile['user']?['profile_photo'] ?? '')
                    .toString();
            final name =
                (controller.userProfile['profile']?['company_name'] ??
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

  Widget _buildUploadForm(BrandController controller) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> pickFile() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedFilePath = result.files.single.path;
            _selectedFileName = result.files.single.name;
          });
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to pick file: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
    }

    Future<void> uploadManual() async {
      if (!formKey.currentState!.validate()) return;
      if (_selectedFilePath == null) {
        Get.snackbar('Error', 'Please select a PDF file',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        return;
      }

      final success = await controller.uploadManual(titleController.text, _selectedFilePath!);
      if (success) {
        setState(() {
          _showUploadForm = false;
          _selectedFilePath = null;
          _selectedFileName = null;
        });
        titleController.clear();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('Title *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: _inputDecoration('e.g. Installation Guide v2.0'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('File (PDF) *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedFileName != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(_selectedFileName!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to select PDF file', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('PDF only — max 10 MB', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _showUploadForm = false;
                        _selectedFilePath = null;
                        _selectedFileName = null;
                      }),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              if (_selectedFilePath == null) {
                                Get.snackbar('Error', 'Please select a PDF file',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor:
                                        Colors.red.withValues(alpha: 0.8));
                                return;
                              }
                              setState(() => _isUploading = true);
                              final success = await controller.uploadManual(
                                  titleController.text, _selectedFilePath!);
                              if (mounted) setState(() => _isUploading = false);
                              if (success) {
                                setState(() {
                                  _showUploadForm = false;
                                  _selectedFilePath = null;
                                  _selectedFileName = null;
                                });
                                titleController.clear();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildManualsList(BrandController controller) {
    return Obx(() {
      if (controller.manualsLoading.value && controller.manuals.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
      }
      if (controller.manuals.isEmpty) {
        return const Center(child: Text('No manuals uploaded yet', style: TextStyle(color: Colors.grey)));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchManuals(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.manuals.length,
          itemBuilder: (context, index) {
            final manual = controller.manuals[index] as Map;
            final fileUrl = manual['file_url'] as String?;
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
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('PDF', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3), fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(manual['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        if (manual['description'] != null && (manual['description'] as String).isNotEmpty)
                          Text(manual['description'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (manual['file_size'] != null)
                              Text('${((manual['file_size'] as num) / 1024).toStringAsFixed(0)} KB', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (manual['file_size'] != null) const SizedBox(width: 12),
                            Text(manual['created_at']?.toString().split('T').first ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (fileUrl != null)
                    IconButton(
                      onPressed: () async {
                        // Make URL absolute if relative
                        final absUrl = fileUrl.startsWith('http')
                            ? fileUrl
                            : 'https://solarpartner.pk$fileUrl';
                        final uri = Uri.parse(absUrl);
                        try {
                          final launched = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched) {
                            Get.snackbar('Error', 'Cannot open file',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    Colors.red.withValues(alpha: 0.8),
                                colorText: Colors.white);
                          }
                        } catch (_) {
                          Get.snackbar('Error', 'Cannot open file',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white);
                        }
                      },
                      icon: const Icon(Icons.download, color: Color(0xFF2196F3)),
                    ),
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Manual'),
                          content: const Text('Are you sure you want to delete this manual?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        controller.deleteManual(manual['id'] as int);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
