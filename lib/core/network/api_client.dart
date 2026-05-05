import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/mock_api_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final GetStorage _storage = GetStorage();

  static String get baseUrl {
    // Check if there's a custom API URL set in storage (for development)
    final customUrl = GetStorage().read('api_base_url');
    if (customUrl != null && customUrl is String && customUrl.isNotEmpty) {
      return customUrl;
    }
    // Default production URL
    return 'https://solarpartner.pk/api';
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _storage.remove('token');
            _storage.remove('user');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    // Check if we should use mock data (when using mock:// scheme)
    if (baseUrl.startsWith('mock://')) {
      print('[ApiClient] Using mock data for GET $path');
      final mockResponse = MockApiService().getMockResponse(path);
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: mockResponse,
      );
    }

    print('[ApiClient] Making real API call for GET $path');
    return await _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    // Check if we should use mock data (when using mock:// scheme)
    if (baseUrl.startsWith('mock://')) {
      final mockResponse = MockApiService().getMockResponse(path, requestData: data as Map<String, dynamic>?);
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: mockResponse,
      );
    }

    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    // Check if we should use mock data (when using mock:// scheme)
    if (baseUrl.startsWith('mock://')) {
      final mockResponse = MockApiService().getMockResponse(path, requestData: data as Map<String, dynamic>?);
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: mockResponse,
      );
    }

    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    // Check if we should use mock data (when using mock:// scheme)
    if (baseUrl.startsWith('mock://')) {
      final mockResponse = MockApiService().getMockResponse(path);
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: mockResponse,
      );
    }

    return await _dio.delete(path);
  }

  Future<Response> postFormData(String path, FormData data) async {
    // Check if we should use mock data (when using mock:// scheme)
    if (baseUrl.startsWith('mock://')) {
      // For form data, convert fields and files to a map
      final requestData = Map<String, dynamic>.fromEntries(data.fields);
      data.files.forEach((file) {
        requestData[file.key] = file.value.filename ?? 'mock_file'; // mock filename
      });
      final mockResponse = MockApiService().getMockResponse(path, requestData: requestData);
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: mockResponse,
      );
    }

    return await _dio.post(
      path,
      data: data,
      options: Options(
        // Let Dio set the correct multipart/form-data boundary automatically
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  void setToken(String token) {
    _storage.write('token', token);
  }

  String? getToken() {
    return _storage.read('token');
  }

  void saveUser(Map<String, dynamic> user) {
    _storage.write('user', user);
  }

  Map<String, dynamic>? getUser() {
    return _storage.read('user');
  }

  void clearAuth() {
    _storage.remove('token');
    _storage.remove('user');
  }

  bool isLoggedIn() {
    return _storage.read('token') != null;
  }

  // Method to set custom API URL (useful for development/testing)
  void setCustomApiUrl(String url) {
    if (url.isNotEmpty) {
      _storage.write('api_base_url', url);
      // Reinitialize Dio with new base URL
      _initializeDio();
    }
  }

  // Method to reset to default production URL
  void resetToDefaultUrl() {
    _storage.remove('api_base_url');
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Re-add interceptors
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _storage.remove('token');
            _storage.remove('user');
          }
          return handler.next(error);
        },
      ),
    );
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? pagination;
  final List<dynamic>? errors;
  final int code;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
    this.errors,
    required this.code,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      pagination: json['pagination'] != null
          ? Map<String, dynamic>.from(json['pagination'] as Map)
          : null,
      errors: json['errors'],
      code: json['code'] ?? 0,
    );
  }

  factory ApiResponse.fromDioError(DioException e) {
    String message = 'An error occurred';
    Map<String, dynamic>? errors;
    int code = 500;

    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? message;
        // Guard: errors must be a Map, not an int/string
        final raw = responseData['errors'];
        errors = (raw is Map<String, dynamic>) ? raw : null;
        code = e.response!.statusCode ?? 500;
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please check your internet.';
          code = 408;
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection.';
          code = 401;
          break;
        default:
          message = 'Server error. Please try again later.';
          code = 500;
      }
    }

    return ApiResponse(
      success: false,
      message: message,
      errors: errors?.values.expand((e) => e as List).toList().cast<String>(),
      code: code,
    );
  }
}
