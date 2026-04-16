import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final apiResponse = ApiResponse.fromJson(data);

      if (apiResponse.success) {
        final userData = apiResponse.data['user'];
        final token = apiResponse.data['token'];

        _client.setToken(token);
        _client.saveUser(Map<String, dynamic>.from(userData));
      }

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> register({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _client.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final data = response.data;
      final apiResponse = ApiResponse.fromJson(data);

      if (apiResponse.success) {
        final userData = apiResponse.data['user'];
        final token = apiResponse.data['token'];

        _client.setToken(token);
        _client.saveUser(Map<String, dynamic>.from(userData));
      }

      return apiResponse;
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> logout() async {
    try {
      final response = await _client.post('/auth/logout');
      final data = response.data;
      final apiResponse = ApiResponse.fromJson(data);

      if (apiResponse.success) {
        _client.clearAuth();
      }

      return apiResponse;
    } on DioException catch (e) {
      _client.clearAuth();
      return ApiResponse.fromDioError(e);
    }
  }

  bool isLoggedIn() => _client.isLoggedIn();

  Map<String, dynamic>? getCurrentUser() => _client.getUser();

  String? getToken() => _client.getToken();
}
