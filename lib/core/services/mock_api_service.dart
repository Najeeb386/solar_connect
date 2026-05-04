import 'package:get_storage/get_storage.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;

  final _storage = GetStorage();

  MockApiService._internal();

  /// Mock API responses for development testing
  ///
  /// Login role detection based on email:
  /// - Contains 'brand', 'admin', or 'company' → Brand role
  /// - Contains 'shop', 'store', or 'retail' → Shopkeeper role
  /// - Everything else → Installer role (default)
  ///
  /// Example test emails:
  /// - brand@test.com or admin@company.com → Brand dashboard
  /// - shop@test.com or store@retail.com → Shopkeeper dashboard
  /// - installer@test.com or any other email → Installer dashboard
  Map<String, dynamic> getMockResponse(String endpoint, {Map<String, dynamic>? requestData}) {
    switch (endpoint) {
      case '/auth/login':
        // Determine role based on email or use a simple mapping
        final email = requestData?['email']?.toString().toLowerCase() ?? '';
        String userRole = 'installer';
        String userName = 'Test User';
        String userEmail = email;

        if (email.contains('brand') || email.contains('admin') || email.contains('company')) {
          userRole = 'brand';
          userName = 'Brand Manager';
          userEmail = email.isEmpty ? 'brand@test.com' : email;
        } else if (email.contains('shop') || email.contains('store') || email.contains('retail')) {
          userRole = 'shopkeeper';
          userName = 'Shop Owner';
          userEmail = email.isEmpty ? 'shop@test.com' : email;
        } else {
          userRole = 'installer';
          userName = 'Test Installer';
          userEmail = email.isEmpty ? 'installer@test.com' : email;
        }

        return {
          'success': true,
          'message': 'Login successful',
          'data': {
            'user': {
              'id': 1,
              'name': userName,
              'email': userEmail,
              'role': userRole,
              'profile_photo': null
            },
            'token': 'mock_token_12345'
          }
        };

      case '/installer/dashboard':
        return {
          'success': true,
          'message': 'Dashboard loaded',
          'data': {
            'user': {
              'id': 1,
              'name': 'Test Installer',
              'email': 'installer@test.com',
              'profile_photo': null
            },
            'stats': {
              'pending_jobs': 2,
              'active_jobs': 1,
              'completed_jobs': 5,
              'wallet_balance': 7000
            },
            'recent_jobs': [
              {
                'id': 1,
                'title': 'Solar Panel Installation',
                'location': 'Lahore, Pakistan',
                'status': 'pending'
              },
              {
                'id': 2,
                'title': 'Inverter Setup',
                'location': 'Karachi, Pakistan',
                'status': 'active'
              }
            ],
            'available_jobs': [
              {
                'id': 3,
                'title': 'Battery Installation',
                'location': 'Islamabad, Pakistan',
                'status': 'available'
              }
            ]
          }
        };

      case '/brand/dashboard':
        return {
          'success': true,
          'message': 'Brand dashboard loaded',
          'data': {
            'user': {
              'id': 1,
              'name': 'Brand Manager',
              'email': 'brand@test.com',
              'profile_photo': null
            },
            'stats': {
              'total_programs': 5,
              'active_programs': 3,
              'total_claims': 25,
              'pending_claims': 8
            }
          }
        };

      case '/shopkeeper/dashboard':
        return {
          'success': true,
          'message': 'Shopkeeper dashboard loaded',
          'data': {
            'user': {
              'id': 1,
              'name': 'Shop Owner',
              'email': 'shop@test.com',
              'profile_photo': null
            },
            'stats': {
              'total_products': 15,
              'active_products': 12,
              'total_sales': 45,
              'pending_orders': 3
            }
          }
        };

      case '/installer/programs':
        return {
          'success': true,
          'message': 'Programs loaded',
          'data': [
            {
              'id': 1,
              'title': 'Solar Panel Installation Program',
              'brand_name': 'Tesla',
              'reward': 5000,
              'end_date': '2026-12-31'
            },
            {
              'id': 2,
              'title': 'Inverter Setup Program',
              'brand_name': 'Huawei',
              'reward': 3000,
              'end_date': '2026-11-30'
            },
            {
              'id': 3,
              'title': 'Battery Installation Program',
              'brand_name': 'LG',
              'reward': 4000,
              'end_date': '2026-10-31'
            }
          ]
        };

      case '/installer/wallet':
        return {
          'success': true,
          'message': 'Wallet data retrieved',
          'data': {
            'current_balance': 7000,
            'total_credited': '7000.00',
            'total_debited': 0,
            'pending_credits': 0,
            'pending_debits': 0
          }
        };

      case '/installer/product-claims':
        return {
          'success': true,
          'message': 'Claims retrieved',
          'data': [
            {
              'id': 1,
              'program_title': 'Solar Panel Installation Program',
              'product_name': 'Tesla Solar Panel 400W',
              'reward': 5000,
              'status': 'approved',
              'created_at': '2026-05-01T10:00:00Z'
            },
            {
              'id': 2,
              'program_title': 'Inverter Setup Program',
              'product_name': 'Huawei Inverter 5KW',
              'reward': 3000,
              'status': 'pending',
              'created_at': '2026-05-02T08:30:00Z'
            }
          ]
        };

      default:
        return {
          'success': false,
          'message': 'Endpoint not mocked: $endpoint',
          'data': null
        };
    }
  }

  // Check if we should use mock data
  bool shouldUseMockData() {
    // Use mock data if API URL is httpbin.org (test mode)
    final apiUrl = _storage.read('api_base_url') ?? 'https://solarpartner.pk/api';
    return apiUrl.contains('httpbin.org');
  }
}