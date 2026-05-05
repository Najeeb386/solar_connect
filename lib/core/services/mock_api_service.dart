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
    // Handle brand endpoints separately
    if (endpoint.startsWith('/brand/')) {
      if (endpoint == '/brand/dashboard') {
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
            },
            'brand_name': 'SolarTech Solutions',
            'programs': [
              {
                'id': 1,
                'title': 'Solar Panel Installation Incentive',
                'description': 'Earn rewards for every solar panel installation completed.',
                'incentive_amount': 5000,
                'is_active': true,
                'is_published': true,
                'products': [
                  {'id': 1, 'product_name': 'Solar Panel 400W'},
                  {'id': 2, 'product_name': 'Solar Panel 500W'}
                ],
                'enrolled_count': 12
              },
              {
                'id': 4,
                'title': 'Complete Solar System Package',
                'description': 'Comprehensive solar system installation program.',
                'incentive_amount': 8000,
                'is_active': true,
                'is_published': true,
                'products': [
                  {'id': 1, 'product_name': 'Solar Panel 400W'},
                  {'id': 2, 'product_name': 'Solar Panel 500W'},
                  {'id': 3, 'product_name': 'Inverter 5KW'},
                  {'id': 4, 'product_name': 'Battery 10KWh'}
                ],
                'enrolled_count': 5
              },
              {
                'id': 5,
                'title': 'Eco-Friendly Installation Campaign',
                'description': 'Promote sustainable energy with special rewards.',
                'incentive_amount': 6000,
                'is_active': true,
                'is_published': true,
                'products': [
                  {'id': 1, 'product_name': 'Solar Panel 400W'},
                  {'id': 3, 'product_name': 'Inverter 5KW'}
                ],
                'enrolled_count': 15
              }
            ]
          }
        };
      } else if (endpoint == '/brand/profile') {
        return {
          'success': true,
          'message': 'Profile retrieved',
          'data': {
            'user': {
              'id': 1,
              'name': 'Brand Manager',
              'email': 'brand@test.com',
              'profile_photo': null
            },
            'profile': {
              'company_name': 'SolarTech Solutions',
              'description': 'Leading solar panel manufacturer',
              'phone': '+92-300-1234567',
              'address': 'Lahore, Pakistan'
            }
          }
        };
      } else if (endpoint == '/brand/notifications') {
        return {
          'success': true,
          'message': 'Notifications retrieved',
          'data': [
            {
              'id': 1,
              'title': 'New Claim Submitted',
              'message': 'A new product claim has been submitted for your program.',
              'created_at': '2026-05-02T10:00:00Z',
              'read': false
            },
            {
              'id': 2,
              'title': 'Program Expiring Soon',
              'message': 'Your solar panel program expires in 7 days.',
              'created_at': '2026-05-01T14:30:00Z',
              'read': true
            }
          ]
        };
      } else if (endpoint == '/brand/programs' && requestData == null) {
        // GET programs
        return {
          'success': true,
          'message': 'Programs retrieved',
          'data': [
            {
              'id': 1,
              'title': 'Solar Panel Installation Incentive',
              'description': 'Earn rewards for every solar panel installation completed.',
              'incentive_amount': 5000,
              'is_active': true,
              'is_published': true,
              'products': [
                {'id': 1, 'product_name': 'Solar Panel 400W'},
                {'id': 2, 'product_name': 'Solar Panel 500W'}
              ],
              'enrolled_count': 12,
              'start_date': '2026-01-01',
              'end_date': '2026-12-31',
              'max_enrollments': 100
            },
            {
              'id': 2,
              'title': 'Inverter Setup Program',
              'description': 'Special incentive for inverter installations.',
              'incentive_amount': 3000,
              'is_active': true,
              'is_published': true,
              'products': [
                {'id': 3, 'product_name': 'Inverter 5KW'}
              ],
              'enrolled_count': 8,
              'start_date': '2026-02-01',
              'end_date': '2026-11-30',
              'max_enrollments': null
            },
            {
              'id': 3,
              'title': 'Battery Installation Bonus',
              'description': 'Bonus for battery system installations.',
              'incentive_amount': 4000,
              'is_active': false,
              'is_published': false,
              'products': [
                {'id': 4, 'product_name': 'Battery 10KWh'}
              ],
              'enrolled_count': 0,
              'start_date': '2026-03-01',
              'end_date': '2026-10-31',
              'max_enrollments': 50
            },
            {
              'id': 4,
              'title': 'Complete Solar System Package',
              'description': 'Comprehensive solar system installation program.',
              'incentive_amount': 8000,
              'is_active': true,
              'is_published': true,
              'products': [
                {'id': 1, 'product_name': 'Solar Panel 400W'},
                {'id': 2, 'product_name': 'Solar Panel 500W'},
                {'id': 3, 'product_name': 'Inverter 5KW'},
                {'id': 4, 'product_name': 'Battery 10KWh'}
              ],
              'enrolled_count': 5,
              'start_date': '2026-01-15',
              'end_date': '2026-12-15',
              'max_enrollments': 25
            },
            {
              'id': 5,
              'title': 'Eco-Friendly Installation Campaign',
              'description': 'Promote sustainable energy with special rewards.',
              'incentive_amount': 6000,
              'is_active': true,
              'is_published': true,
              'products': [
                {'id': 1, 'product_name': 'Solar Panel 400W'},
                {'id': 3, 'product_name': 'Inverter 5KW'}
              ],
              'enrolled_count': 15,
              'start_date': '2026-04-01',
              'end_date': '2026-09-30',
              'max_enrollments': 200
            }
          ]
        };
      } else if (endpoint == '/brand/programs' && requestData != null) {
        // POST create program
        final newId = 6; // mock new id
        final created = Map<String, dynamic>.from(requestData);
        created['id'] = newId;
        created['enrolled_count'] = 0;
        created['is_active'] = true;
        created['is_published'] = false;
        return {
          'success': true,
          'message': 'Program created successfully',
          'data': created
        };
      } else if (endpoint.startsWith('/brand/programs/')) {
        final parts = endpoint.split('/');
        if (parts.length == 4) {
          final programId = int.tryParse(parts[3]);
          if (programId != null) {
            if (requestData != null) {
              // PUT update
              final updated = Map<String, dynamic>.from(requestData);
              updated['id'] = programId;
              return {
                'success': true,
                'message': 'Program updated successfully',
                'data': updated
              };
            } else {
              // DELETE
              return {
                'success': true,
                'message': 'Program deleted successfully',
                'data': null
              };
            }
          }
        }
      } else if (endpoint == '/brand/products') {
        return {
          'success': true,
          'message': 'Products retrieved',
          'data': [
            {
              'id': 1,
              'product_name': 'Solar Panel 400W',
              'product_series': 'Premium Series',
              'description': 'High-efficiency solar panel for residential use',
              'photo': null
            },
            {
              'id': 2,
              'product_name': 'Solar Panel 500W',
              'product_series': 'Ultra Series',
              'description': 'Ultra-high efficiency solar panel',
              'photo': null
            },
            {
              'id': 3,
              'product_name': 'Inverter 5KW',
              'product_series': 'Power Series',
              'description': '5KW solar inverter with MPPT technology',
              'photo': null
            },
            {
              'id': 4,
              'product_name': 'Battery 10KWh',
              'product_series': 'Storage Series',
              'description': '10KWh lithium-ion battery storage system',
              'photo': null
            },
            {
              'id': 5,
              'product_name': 'Solar Panel 300W',
              'product_series': 'Economy Series',
              'description': 'Cost-effective solar panel for basic installations',
              'photo': null
            }
          ]
        };
      }
      return {
        'success': false,
        'message': 'Endpoint not mocked: $endpoint',
        'data': null
      };
    }

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
            },
            'shop_name': 'Solar Shop Lahore'
          }
        };

      case '/shopkeeper/profile':
        return {
          'success': true,
          'message': 'Profile retrieved',
          'data': {
            'user': {
              'id': 1,
              'name': 'Shop Owner',
              'email': 'shop@test.com',
              'profile_photo': null
            },
            'profile': {
              'company_name': 'Solar Shop Lahore',
              'description': 'Authorized solar products dealer',
              'phone': '+92-301-7654321',
              'address': 'Gulberg, Lahore, Pakistan'
            }
          }
        };

      case '/shopkeeper/notifications':
        return {
          'success': true,
          'message': 'Notifications retrieved',
          'data': [
            {
              'id': 1,
              'title': 'New Product Available',
              'message': 'New solar panels are now available for order.',
              'created_at': '2026-05-02T09:00:00Z',
              'read': false
            },
            {
              'id': 2,
              'title': 'Order Shipped',
              'message': 'Your order #12345 has been shipped.',
              'created_at': '2026-05-01T16:45:00Z',
              'read': true
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
    // Use mock data if API URL starts with mock:// (test mode)
    final apiUrl = _storage.read('api_base_url') ?? 'https://solarpartner.pk/api';
    return apiUrl.startsWith('mock://');
  }
}