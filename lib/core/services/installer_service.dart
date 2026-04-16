import 'package:dio/dio.dart';
import '../network/api_client.dart';

class InstallerService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getDashboard() async {
    try {
      final response = await _client.get('/installer/dashboard');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final response = await _client.get('/installer/profile');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/installer/profile', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getKycStatus() async {
    try {
      final response = await _client.get('/installer/kyc');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> submitKyc({
    required String cnicNumber,
    required String cnicFrontPath,
    required String cnicBackPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'cnic_number': cnicNumber,
        'cnic_front': await MultipartFile.fromFile(cnicFrontPath),
        'cnic_back': await MultipartFile.fromFile(cnicBackPath),
      });
      final response = await _client.postFormData('/installer/kyc', formData);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getJobs({
    int page = 1,
    String? city,
    String? region,
    String? status,
    String? sort,
  }) async {
    try {
      final response = await _client.get(
        '/installer/jobs',
        queryParams: {
          'page': page,
          if (city != null) 'city': city,
          if (region != null) 'region': region,
          if (status != null) 'status': status,
          if (sort != null) 'sort': sort,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getMyJobs({int page = 1}) async {
    try {
      final response = await _client.get(
        '/installer/jobs/my-jobs',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getJobDetails(int jobId) async {
    try {
      final response = await _client.get('/installer/jobs/$jobId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> acceptJob(int jobId) async {
    try {
      final response = await _client.post('/installer/jobs/$jobId/accept');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> startJob(int jobId) async {
    try {
      final response = await _client.post('/installer/jobs/$jobId/start');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> completeJob(int jobId) async {
    try {
      final response = await _client.post('/installer/jobs/$jobId/complete');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getWallet() async {
    try {
      final response = await _client.get('/installer/wallet');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> withdraw(int paymentMethodId, double amount) async {
    try {
      final response = await _client.post(
        '/installer/wallet/withdraw',
        data: {'payment_method_id': paymentMethodId, 'amount': amount},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getPaymentMethods() async {
    try {
      final response = await _client.get('/installer/payment-methods');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> addPaymentMethod({
    required String type,
    required String accountName,
    required String accountNumber,
    String? ibanNumber,
  }) async {
    try {
      final response = await _client.post(
        '/installer/payment-methods',
        data: {
          'type': type,
          'account_name': accountName,
          'account_number': accountNumber,
          if (ibanNumber != null) 'iban_number': ibanNumber,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getPrograms({int page = 1}) async {
    try {
      final response = await _client.get(
        '/installer/programs',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> enrollInProgram(int programId) async {
    try {
      final response = await _client.post(
        '/installer/programs/$programId/enroll',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getNearbyShops({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _client.get(
        '/installer/nearby-shops',
        queryParams: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
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

  Future<ApiResponse> markNotificationRead(int notificationId) async {
    try {
      final response = await _client.post(
        '/notifications/$notificationId/read',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> uploadProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profile_photo': await MultipartFile.fromFile(filePath),
      });
      final response = await _client.postFormData(
        '/installer/profile/upload-photo',
        formData,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
