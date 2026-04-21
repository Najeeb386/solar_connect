import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_partner/core/services/shopkeeper_service.dart';

class ShopkeeperController extends GetxController {
  final ShopkeeperService _service = ShopkeeperService();

  final RxMap dashboardData = {}.obs;
  final RxMap userProfile = {}.obs;

  final RxList jobs = [].obs;
  final RxBool jobsLoading = false.obs;
  int _jobsPage = 1;
  bool _hasMoreJobs = true;

  final RxList installers = [].obs;
  final RxBool installersLoading = false.obs;

  final RxList notifications = [].obs;
  final RxBool notificationsLoading = false.obs;
  final RxInt unreadNotifications = 0.obs;

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchProfile();
  }

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 1:
        if (jobs.isEmpty) fetchJobs(refresh: true);
        break;
      case 2:
        if (installers.isEmpty) fetchInstallers();
        break;
      case 3:
        fetchNotifications();
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
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _service.getProfile();
      if (res.success && res.data != null) {
        userProfile.value = Map<String, dynamic>.from(res.data as Map);
        // Inject user into dashboardData so drawer works
        final current = Map<String, dynamic>.from(dashboardData);
        current['user'] = (res.data as Map)['user'];
        dashboardData.value = current;
        // Sync GetStorage
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
    try {
      final res = await _service.updateProfile(data);
      if (res.success) {
        await fetchProfile();
        final storage = GetStorage();
        final storedUser = storage.read('user') ?? {};
        if (data['name'] != null) storedUser['name'] = data['name'];
        storage.write('user', storedUser);
        Get.snackbar('Success', res.message ?? 'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return false;
    }
  }

  Future<void> fetchJobs({bool refresh = false, String? status}) async {
    try {
      if (refresh) {
        jobs.clear();
        _jobsPage = 1;
        _hasMoreJobs = true;
      }
      if (!_hasMoreJobs) return;
      jobsLoading.value = true;
      final res = await _service.getJobs(page: _jobsPage, status: status);
      jobsLoading.value = false;
      if (res.success && res.data != null) {
        final list = (res.data as List? ?? []);
        // last_page comes from res.pagination (server returns separate pagination key)
        final lastPage = (res.pagination?['last_page'] ?? 1) as int;
        if (refresh || _jobsPage == 1) {
          jobs.value = list;
        } else {
          jobs.addAll(list);
        }
        if (_jobsPage >= lastPage) _hasMoreJobs = false;
        _jobsPage++;
      } else {
        if (refresh) {
          Get.snackbar('Error', res.message ?? 'Failed to load jobs',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8));
        }
      }
    } catch (e) {
      jobsLoading.value = false;
      Get.snackbar('Error', 'Connection failed while loading jobs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8));
    }
  }

  Future<bool> createJob(Map<String, dynamic> data) async {
    try {
      final res = await _service.createJob(data);
      if (res.success) {
        await fetchJobs(refresh: true);
        await fetchDashboard();
        Get.snackbar('Job Posted!', res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to create job',
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

  Future<bool> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final res = await _service.updateJob(jobId, data);
      if (res.success) {
        await fetchJobs(refresh: true);
        Get.snackbar('Updated', res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to update job',
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

  Future<bool> deleteJob(int jobId) async {
    try {
      final res = await _service.deleteJob(jobId);
      if (res.success) {
        await fetchJobs(refresh: true);
        await fetchDashboard();
        Get.snackbar('Deleted', 'Job deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to delete job',
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

  Future<List> fetchJobAssignments(int jobId) async {
    try {
      final res = await _service.getJobAssignments(jobId);
      if (res.success && res.data != null) {
        return res.data as List? ?? [];
      }
      return [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assignments',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8));
      return [];
    }
  }

  Future<bool> hireInstaller(int jobId, int installerId) async {
    try {
      final res = await _service.hireInstaller(jobId, installerId);
      if (res.success) {
        await fetchJobs(refresh: true);
        Get.snackbar('Hired!', res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to hire installer',
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

  Future<bool> releasePayment(
      int jobId, int installerId, double amount) async {
    try {
      final res = await _service.releasePayment(jobId,
          installerId: installerId, amount: amount);
      if (res.success) {
        await fetchJobs(refresh: true);
        await fetchDashboard();
        Get.snackbar('Payment Released', res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to release payment',
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

  Future<bool> raiseDispute(
      int jobId, int installerId, String reason) async {
    try {
      final res = await _service.raiseDispute(jobId,
          installerId: installerId, reason: reason);
      if (res.success) {
        Get.snackbar('Dispute Raised', res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
        return true;
      }
      Get.snackbar('Error', res.message ?? 'Failed to raise dispute',
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

  Future<void> fetchInstallers(
      {String? city, String? skills, String? region}) async {
    try {
      installersLoading.value = true;
      final res =
          await _service.getInstallers(city: city, skills: skills, region: region);
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
        // unread_count comes from pagination key (server puts it there)
        if (res.pagination != null) {
          unreadNotifications.value =
              (res.pagination!['unread_count'] ?? 0) as int;
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
}
