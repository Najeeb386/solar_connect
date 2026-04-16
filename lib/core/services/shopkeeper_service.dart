import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ShopkeeperService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getDashboard() async {
    try {
      final response = await _client.get('/shopkeeper/dashboard');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final response = await _client.get('/shopkeeper/profile');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/shopkeeper/profile', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getJobs({
    int page = 1,
    String? status,
    String? city,
  }) async {
    try {
      final response = await _client.get(
        '/shopkeeper/jobs',
        queryParams: {
          'page': page,
          if (status != null) 'status': status,
          if (city != null) 'city': city,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> createJob(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/shopkeeper/jobs', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getJobDetails(int jobId) async {
    try {
      final response = await _client.get('/shopkeeper/jobs/$jobId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/shopkeeper/jobs/$jobId', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> deleteJob(int jobId) async {
    try {
      final response = await _client.delete('/shopkeeper/jobs/$jobId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getJobAssignments(int jobId) async {
    try {
      final response = await _client.get('/shopkeeper/jobs/$jobId/assignments');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> hireInstaller(int jobId, int installerId) async {
    try {
      final response = await _client.post(
        '/shopkeeper/jobs/$jobId/hire/$installerId',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> releasePayment(int jobId) async {
    try {
      final response = await _client.post(
        '/shopkeeper/jobs/$jobId/release-payment',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> raiseDispute(int jobId, String reason) async {
    try {
      final response = await _client.post(
        '/shopkeeper/jobs/$jobId/dispute',
        data: {'reason': reason},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getInstallers({
    int page = 1,
    String? city,
    String? region,
    double? rating,
    String? skills,
  }) async {
    try {
      final response = await _client.get(
        '/shopkeeper/installers',
        queryParams: {
          'page': page,
          if (city != null) 'city': city,
          if (region != null) 'region': region,
          if (rating != null) 'rating': rating,
          if (skills != null) 'skills': skills,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getInstallerProfile(int installerId) async {
    try {
      final response = await _client.get('/shopkeeper/installers/$installerId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getNotifications({int page = 1}) async {
    try {
      final response = await _client.get(
        '/notifications',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
