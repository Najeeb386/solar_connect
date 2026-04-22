import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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
    required XFile cnicFront,
    required XFile cnicBack,
  }) async {
    try {
      final frontBytes = await cnicFront.readAsBytes();
      final backBytes = await cnicBack.readAsBytes();
      final formData = FormData.fromMap({
        'cnic_number': cnicNumber,
        'cnic_front': MultipartFile.fromBytes(
          frontBytes,
          filename: cnicFront.name.isNotEmpty ? cnicFront.name : 'front.jpg',
        ),
        'cnic_back': MultipartFile.fromBytes(
          backBytes,
          filename: cnicBack.name.isNotEmpty ? cnicBack.name : 'back.jpg',
        ),
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

  Future<ApiResponse> completeJob(int jobId, {String? notes}) async {
    try {
      final response = await _client.post(
        '/installer/jobs/$jobId/complete',
        data: notes != null ? {'notes': notes} : {},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> confirmPaymentReceived(int jobId) async {
    try {
      final response = await _client.post(
        '/installer/jobs/$jobId/payment-received',
      );
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

  Future<ApiResponse> getTopPrograms({int limit = 3}) async {
    try {
      final response = await _client.get(
        '/installer/programs',
        queryParams: {'per_page': limit},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> setDefaultPaymentMethod(int paymentMethodId) async {
    try {
      final response = await _client.post(
        '/installer/payment-methods/$paymentMethodId/set-primary',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> enrollInProgram(
    int programId, {
    required int productId,
  }) async {
    try {
      final response = await _client.post(
        '/installer/programs/$programId/enroll',
        data: {'product_id': productId},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getNearbyShops({
    double? latitude,
    double? longitude,
    int radius = 5000,
  }) async {
    try {
      final response = await _client.get(
        '/installer/nearby-shops',
        queryParams: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'radius': radius,
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

  Future<ApiResponse> uploadProfilePhoto(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'photo.jpg';
      final formData = FormData.fromMap({
        'profile_photo': MultipartFile.fromBytes(bytes, filename: filename),
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

  Future<ApiResponse> getProductClaims({
    String? status,
    int? programId,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (programId != null) queryParams['program_id'] = programId;

      final response = await _client.get(
        '/installer/product-claims',
        queryParams: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getEnrolledPrograms() async {
    try {
      final response = await _client.get(
        '/installer/product-claims/programs/available',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> submitProductClaim({
    required int programId,
    required int productId,
    required Uint8List imageBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'program_id': programId,
        'product_id': productId,
        'barcode_image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'barcode.jpg',
        ),
      });
      final response = await _client.postFormData(
        '/installer/product-claims',
        formData,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
