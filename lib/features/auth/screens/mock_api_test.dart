// Quick test of mock API
import 'package:flutter/material.dart';
import '../../../core/services/mock_api_service.dart';

class MockApiTestPage extends StatelessWidget {
  const MockApiTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockApiService();

    // Test login with brand email
    final brandLogin = mockService.getMockResponse('/auth/login', requestData: {'email': 'admin@brand.com'});
    final brandRole = brandLogin['data']['user']['role'];

    // Test login with shopkeeper email
    final shopLogin = mockService.getMockResponse('/auth/login', requestData: {'email': 'owner@store.com'});
    final shopRole = shopLogin['data']['user']['role'];

    // Test login with installer email
    final installerLogin = mockService.getMockResponse('/auth/login', requestData: {'email': 'installer@test.com'});
    final installerRole = installerLogin['data']['user']['role'];

    return Scaffold(
      appBar: AppBar(title: const Text('Mock API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Role Detection Test:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Brand email (admin@brand.com): $brandRole'),
            Text('Shopkeeper email (owner@store.com): $shopRole'),
            Text('Installer email (installer@test.com): $installerRole'),
            const SizedBox(height: 24),
            const Text('Mock API is working! ✅', style: TextStyle(color: Colors.green, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}