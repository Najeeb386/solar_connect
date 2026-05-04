import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  final TextEditingController _urlController = TextEditingController();
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    final customUrl = _storage.read('api_base_url');
    _urlController.text = customUrl ?? 'https://solarpartner.pk/api';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('API Configuration'),
        backgroundColor: const Color(0xFFFF8F00),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current API URL:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _urlController.text,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set Custom API URL:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'e.g., http://localhost:8000/api',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _setCustomUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Set Custom URL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefault,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF8F00)),
                      foregroundColor: const Color(0xFFFF8F00),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reset to Default'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPresetButton('Local (Android)', 'http://10.0.2.2:8000/api'),
            _buildPresetButton('Local (iOS)', 'http://localhost:8000/api'),
            _buildPresetButton('Staging', 'https://staging.solarpartner.pk/api'),
            _buildPresetButton('Production', 'https://solarpartner.pk/api'),
            const SizedBox(height: 24),
            const Text(
              'Note: Changes take effect immediately. Test login after changing URL.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _setUrl(url),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFF8F00)),
            foregroundColor: const Color(0xFFFF8F00),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  void _setCustomUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a valid URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    _setUrl(url);
  }

  void _setUrl(String url) {
    _storage.write('api_base_url', url);
    _urlController.text = url;
    setState(() {});
    Get.snackbar(
      'Success',
      'API URL updated to: $url\nRestart the app to apply changes.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _resetToDefault() {
    _storage.remove('api_base_url');
    _urlController.text = 'https://solarpartner.pk/api';
    setState(() {});
    Get.snackbar(
      'Success',
      'Reset to default production URL\nRestart the app to apply changes.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}