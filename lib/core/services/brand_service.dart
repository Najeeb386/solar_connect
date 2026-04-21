import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../network/api_client.dart';

class BrandService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse> getDashboard() async {
    try {
      final response = await _client.get('/brand/dashboard');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final response = await _client.get('/brand/profile');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.put('/brand/profile', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getPrograms({int page = 1}) async {
    try {
      final response = await _client.get(
        '/brand/programs',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> createProgram(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/brand/programs', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProgramDetails(int programId) async {
    try {
      final response = await _client.get('/brand/programs/$programId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateProgram(
    int programId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        '/brand/programs/$programId',
        data: data,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> deleteProgram(int programId) async {
    try {
      final response = await _client.delete('/brand/programs/$programId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProgramEnrollments(int programId) async {
    try {
      final response = await _client.get(
        '/brand/programs/$programId/enrollments',
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getManuals({int page = 1}) async {
    try {
      final response = await _client.get(
        '/brand/manuals',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> uploadManual(String title, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _client.postFormData('/brand/manuals', formData);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> deleteManual(int manualId) async {
    try {
      final response = await _client.delete('/brand/manuals/$manualId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getAnnouncements({int page = 1}) async {
    try {
      final response = await _client.get(
        '/brand/announcements',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> createAnnouncement(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('/brand/announcements', data: data);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> deleteAnnouncement(int announcementId) async {
    try {
      final response = await _client.delete(
        '/brand/announcements/$announcementId',
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
        '/brand/installers',
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
      final response = await _client.get('/brand/installers/$installerId');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getNotifications({int page = 1}) async {
    try {
      final response = await _client.get(
        '/brand/notifications',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProducts({int page = 1}) async {
    try {
      final response = await _client.get(
        '/brand/products',
        queryParams: {'page': page},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<MultipartFile?> _toMultipart(XFile? image) async {
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    final filename = image.name.isNotEmpty ? image.name : 'photo.jpg';
    return MultipartFile.fromBytes(bytes, filename: filename);
  }

  Future<ApiResponse> createProduct(
    String name,
    String series,
    String description,
    XFile? image,
  ) async {
    try {
      final photo = await _toMultipart(image);
      final formData = FormData.fromMap({
        'product_name': name,
        'product_series': series,
        'description': description,
        if (photo != null) 'photo': photo,
      });
      final response = await _client.postFormData('/brand/products', formData);
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> updateProduct(
    int productId,
    String name,
    String series,
    String description,
    XFile? image,
  ) async {
    try {
      final photo = await _toMultipart(image);
      final formData = FormData.fromMap({
        '_method': 'PUT', // Laravel method spoofing — PUT via multipart POST
        'product_name': name,
        'product_series': series,
        'description': description,
        if (photo != null) 'photo': photo,
      });
      final response = await _client.postFormData(
        '/brand/products/$productId',
        formData,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> deleteProduct(int productId) async {
    try {
      final response = await _client.delete('/brand/products/$productId');
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
        '/brand/product-claims',
        queryParams: queryParams,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> approveProductClaim(int claimId) async {
    try {
      final response = await _client.post(
        '/brand/product-claims/$claimId/approve',
        data: {},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> rejectProductClaim({
    required int claimId,
    required String rejectionReason,
  }) async {
    try {
      final response = await _client.post(
        '/brand/product-claims/$claimId/reject',
        data: {'rejection_reason': rejectionReason},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse> getProductClaimStats() async {
    try {
      final response = await _client.get('/brand/product-claims/stats');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
