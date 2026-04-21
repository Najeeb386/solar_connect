import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_partner/core/services/brand_service.dart';

class BrandController extends GetxController {
  final BrandService _service = BrandService();

  final RxMap dashboardData = {}.obs;
  final RxMap userProfile = {}.obs;

  final RxList programs = [].obs;
  final RxBool programsLoading = false.obs;

  final RxList announcements = [].obs;
  final RxBool announcementsLoading = false.obs;

  final RxList manuals = [].obs;
  final RxBool manualsLoading = false.obs;

  final RxList products = [].obs;
  final RxBool productsLoading = false.obs;

  final RxList installers = [].obs;
  final RxBool installersLoading = false.obs;

  final RxList notifications = [].obs;
  final RxBool notificationsLoading = false.obs;
  final RxInt unreadNotifications = 0.obs;

  final RxList productClaims = [].obs;
  final RxBool claimsLoading = false.obs;
  final RxMap claimStats = <String, dynamic>{
    'pending': 0,
    'approved': 0,
    'rejected': 0,
  }.obs;

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchProfile();
    fetchNotifications();
  }

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 1:
        if (programs.isEmpty) fetchPrograms(refresh: true);
        break;
      case 2:
        if (products.isEmpty) fetchProducts(refresh: true);
        break;
      case 3:
        if (productClaims.isEmpty) fetchProductClaims();
        break;
      case 4:
        if (announcements.isEmpty) fetchAnnouncements(refresh: true);
        break;
      case 5:
        if (manuals.isEmpty) fetchManuals(refresh: true);
        break;
      case 6:
        // Analytics - refresh dashboard + programs
        if (dashboardData.isEmpty) fetchDashboard();
        if (programs.isEmpty) fetchPrograms(refresh: true);
        if (claimStats['pending'] == 0 && claimStats['approved'] == 0) {
          getProductClaimStats().then((stats) {
            if (stats != null) claimStats.value = stats;
          });
        }
        break;
      case 7:
        // Profile - nothing to load
        break;
    }
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      final res = await _service.getDashboard();
      isLoading.value = false;
      if (res.success && res.data != null) {
        dashboardData.value = Map<String, dynamic>.from(res.data as Map);
      } else {
        Get.snackbar('Error', res.message ?? 'Failed to load dashboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Connection failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _service.getProfile();
      if (res.success && res.data != null) {
        userProfile.value = Map<String, dynamic>.from(res.data as Map);
        final current = Map<String, dynamic>.from(dashboardData);
        current['user'] = (res.data as Map)['user'];
        dashboardData.value = current;
        final storage = GetStorage();
        final userData = (res.data as Map)['user'];
        if (userData != null) {
          storage.write('user', Map<String, dynamic>.from(userData as Map));
        }
      } else {
        Get.snackbar('Error', res.message ?? 'Failed to load profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final res = await _service.updateProfile(data);
    if (res.success) {
      await fetchProfile();
      final storage = GetStorage();
      final storedUser = storage.read('user') ?? {};
      if (data['company_name'] != null) storedUser['name'] = data['company_name'];
      storage.write('user', storedUser);
      Get.snackbar('Updated', res.message, snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      return true;
    }
    Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<void> fetchPrograms({bool refresh = false}) async {
    try {
      if (refresh) programs.clear();
      programsLoading.value = true;
      final res = await _service.getPrograms();
      programsLoading.value = false;
      if (res.success && res.data != null) {
        programs.value = res.data as List? ?? [];
      } else {
        if (refresh) {
          Get.snackbar('Error', res.message ?? 'Failed to load programs',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        }
      }
    } catch (e) {
      programsLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> createProgram(Map<String, dynamic> data) async {
    try {
      final res = await _service.createProgram(data);
      if (res.success) {
        fetchPrograms(refresh: true); // refresh list before navigating back
        Get.back(); // auto-back to programs list
        Get.snackbar('Created', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to create program',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> updateProgram(int programId, Map<String, dynamic> data) async {
    try {
      final res = await _service.updateProgram(programId, data);
      if (res.success) {
        fetchPrograms(refresh: true); // refresh list before navigating back
        Get.back(); // auto-back to programs list
        Get.snackbar('Updated', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to update program',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> deleteProgram(int programId) async {
    try {
      final res = await _service.deleteProgram(programId);
      if (res.success) {
        await fetchPrograms(refresh: true);
        await fetchDashboard();
        Get.snackbar('Deleted', 'Program deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to delete program',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<List> fetchProgramEnrollments(int programId) async {
    try {
      final res = await _service.getProgramEnrollments(programId);
      if (res.success && res.data != null) {
        return res.data as List? ?? [];
      }
      return [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load enrollments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return [];
    }
  }

  Future<void> fetchAnnouncements({bool refresh = false}) async {
    try {
      if (refresh) announcements.clear();
      announcementsLoading.value = true;
      final res = await _service.getAnnouncements();
      announcementsLoading.value = false;
      if (res.success && res.data != null) {
        announcements.value = res.data as List? ?? [];
      } else {
        if (refresh) {
          Get.snackbar('Error', res.message ?? 'Failed to load announcements',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        }
      }
    } catch (e) {
      announcementsLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> createAnnouncement(Map<String, dynamic> data) async {
    try {
      final res = await _service.createAnnouncement(data);
      if (res.success) {
        await fetchAnnouncements(refresh: true);
        Get.snackbar('Posted', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to post announcement',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> deleteAnnouncement(int id) async {
    try {
      final res = await _service.deleteAnnouncement(id);
      if (res.success) {
        await fetchAnnouncements(refresh: true);
        Get.snackbar('Deleted', 'Announcement deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to delete announcement',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<void> fetchManuals({bool refresh = false}) async {
    try {
      if (refresh) manuals.clear();
      manualsLoading.value = true;
      final res = await _service.getManuals();
      manualsLoading.value = false;
      if (res.success && res.data != null) {
        manuals.value = res.data as List? ?? [];
      } else {
        if (refresh) {
          Get.snackbar('Error', res.message ?? 'Failed to load manuals',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        }
      }
    } catch (e) {
      manualsLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> uploadManual(String title, String filePath) async {
    try {
      final res = await _service.uploadManual(title, filePath);
      if (res.success) {
        await fetchManuals(refresh: true);
        Get.snackbar('Uploaded', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to upload manual',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> deleteManual(int id) async {
    try {
      final res = await _service.deleteManual(id);
      if (res.success) {
        await fetchManuals(refresh: true);
        Get.snackbar('Deleted', 'Manual deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to delete manual',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    try {
      if (refresh) products.clear();
      productsLoading.value = true;
      final res = await _service.getProducts();
      productsLoading.value = false;
      if (res.success && res.data != null) {
        products.value = res.data as List? ?? [];
      } else {
        if (refresh) {
          Get.snackbar('Error', res.message ?? 'Failed to load products',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        }
      }
    } catch (e) {
      productsLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> createProduct(String name, String series, String description, XFile? image) async {
    try {
      final res = await _service.createProduct(name, series, description, image);
      if (res.success) {
        await fetchProducts(refresh: true);
        Get.snackbar('Created', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to create product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> updateProduct(int productId, String name, String series, String description, XFile? image) async {
    try {
      final res = await _service.updateProduct(productId, name, series, description, image);
      if (res.success) {
        await fetchProducts(refresh: true);
        Get.snackbar('Updated', res.message, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to update product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      final res = await _service.deleteProduct(productId);
      if (res.success) {
        await fetchProducts(refresh: true);
        Get.snackbar('Deleted', res.message ?? 'Product deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to delete product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<void> fetchInstallers({String? city, String? skills, String? region}) async {
    try {
      installersLoading.value = true;
      final res = await _service.getInstallers(city: city, skills: skills, region: region);
      installersLoading.value = false;
      if (res.success && res.data != null) {
        installers.value = res.data as List? ?? [];
      } else {
        Get.snackbar('Error', res.message ?? 'Failed to load installers',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
    } catch (e) {
      installersLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<Map?> getInstallerDetail(int installerId) async {
    try {
      final res = await _service.getInstallerProfile(installerId);
      if (res.success && res.data != null) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load installer details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return null;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      notificationsLoading.value = true;
      final res = await _service.getNotifications();
      notificationsLoading.value = false;
      if (res.success && res.data != null) {
        notifications.value = res.data as List? ?? [];
        if (res.pagination != null) {
          unreadNotifications.value = (res.pagination!['unread_count'] ?? 0) as int;
        }
      } else {
        Get.snackbar('Error', res.message ?? 'Failed to load notifications',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
    } catch (e) {
      notificationsLoading.value = false;
      Get.snackbar('Error', 'Failed to load notifications',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<void> fetchProductClaims({String? status, int? programId}) async {
    try {
      claimsLoading.value = true;
      final res = await _service.getProductClaims(status: status, programId: programId);
      claimsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list = (raw is Map ? (raw['data'] ?? []) : raw) as List?;
        if (list != null) productClaims.value = list;
      } else {
        Get.snackbar('Error', res.message ?? 'Failed to load claims',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
      }
      // Load stats
      final stats = await getProductClaimStats();
      if (stats != null) {
        claimStats.value = stats;
      }
    } catch (e) {
      claimsLoading.value = false;
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> approveProductClaim(int claimId) async {
    try {
      final res = await _service.approveProductClaim(claimId);
      if (res.success) {
        Get.snackbar('Approved', res.message ?? 'Claim approved and payment released',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        await fetchProductClaims();
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to approve claim',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<bool> rejectProductClaim({
    required int claimId,
    required String rejectionReason,
  }) async {
    try {
      final res = await _service.rejectProductClaim(
        claimId: claimId,
        rejectionReason: rejectionReason,
      );
      if (res.success) {
        Get.snackbar('Rejected', res.message ?? 'Claim rejected',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        await fetchProductClaims();
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to reject claim',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return false;
    }
  }

  Future<Map?> getProductClaimStats() async {
    try {
      final res = await _service.getProductClaimStats();
      if (res.success && res.data != null) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
