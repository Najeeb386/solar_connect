import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/installer_service.dart';

class InstallerController extends GetxController {
  final InstallerService _service = InstallerService();

  // Dashboard
  final RxMap dashboardData = {}.obs;

  // Profile
  final RxMap userProfile = {}.obs;

  // Jobs
  final RxList jobs = [].obs;
  final RxList myJobs = [].obs;
  final RxBool jobsLoading = false.obs;
  final RxBool myJobsLoading = false.obs;
  int _jobsPage = 1;
  int _myJobsPage = 1;

  // Wallet
  final RxMap walletData = {}.obs;
  final RxList transactions = [].obs;
  final RxBool walletLoading = false.obs;

  // Payment Methods
  final RxList paymentMethods = [].obs;

  // Programs
  final RxList programs = [].obs;
  final RxBool programsLoading = false.obs;

  // Nearby Shops
  final RxList nearbyShops = [].obs;
  final RxBool shopsLoading = false.obs;

  // Product Claims
  final RxList productClaims = [].obs;
  final RxList enrolledPrograms = [].obs;
  final RxBool claimsLoading = false.obs;

  // Notifications
  final RxList notifications = [].obs;
  final RxBool notificationsLoading = false.obs;

  // Top Programs for Slider
  final RxList topPrograms = [].obs;

  // Navigation
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool kycApprovedBannerDismissed = false.obs;
  final RxBool kycRejectedBannerDismissed = false.obs;

  @override
  void onInit() {
    super.onInit();
    final s = GetStorage();
    kycApprovedBannerDismissed.value =
        s.read('kyc_approved_banner_dismissed') == true;
    kycRejectedBannerDismissed.value =
        s.read('kyc_rejected_banner_dismissed') == true;
    fetchDashboard();
    fetchProfile();
    fetchTopPrograms();
  }

  void dismissKycApprovedBanner() {
    kycApprovedBannerDismissed.value = true;
    GetStorage().write('kyc_approved_banner_dismissed', true);
  }

  void dismissKycRejectedBanner() {
    kycRejectedBannerDismissed.value = true;
    GetStorage().write('kyc_rejected_banner_dismissed', true);
  }

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 1:
        if (jobs.isEmpty) fetchJobs();
        break;
      case 2:
        if (myJobs.isEmpty) fetchMyJobs();
        break;
      case 3:
        fetchNotifications();
        break;
      case 4:
        if (walletData.isEmpty) fetchWallet();
        break;
      case 5:
        if (nearbyShops.isEmpty) fetchNearbyShops();
        break;
      case 6:
        if (programs.isEmpty) fetchPrograms();
        break;
      case 7:
        if (enrolledPrograms.isEmpty) fetchEnrolledPrograms();
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
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load dashboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await _service.getProfile();
      if (res.success && res.data != null) {
        userProfile.value = Map<String, dynamic>.from(res.data as Map);
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchTopPrograms() async {
    try {
      programsLoading.value = true;
      final res = await _service.getTopPrograms(limit: 5);
      programsLoading.value = false;

      if (res.success && res.data != null) {
        final programsData = res.data['programs'] ?? [];
        if (programsData is List && programsData.isNotEmpty) {
          // Filter active programs and sort by reward amount
          final now = DateTime.now();
          final activePrograms = programsData.where((p) {
            if (p is! Map) return false;
            final expiryDateStr = p['end_date']?.toString() ?? '';
            if (expiryDateStr.isEmpty) return false;
            try {
              final expiryDate = DateTime.parse(expiryDateStr);
              return expiryDate.isAfter(now);
            } catch (e) {
              return false;
            }
          }).toList();

          // Sort by highest reward
          activePrograms.sort((a, b) {
            final aReward =
                double.tryParse(a['reward']?.toString() ?? '0') ?? 0;
            final bReward =
                double.tryParse(b['reward']?.toString() ?? '0') ?? 0;
            return bReward.compareTo(aReward);
          });

          topPrograms.value = List.from(activePrograms.take(3));
        }
      }
    } catch (e) {
      programsLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final res = await _service.updateProfile(data);
    if (res.success) {
      await fetchProfile();
      // Also update user data in dashboardData so drawer name refreshes
      if (res.data != null) {
        final updatedUser = res.data is Map ? res.data : null;
        if (updatedUser != null) {
          final current = Map<String, dynamic>.from(dashboardData);
          current['user'] = updatedUser;
          dashboardData.value = current;
        }
      }
      // Also update GetStorage cached user name
      final storage = GetStorage();
      final storedUser = storage.read('user') ?? {};
      if (data['name'] != null) storedUser['name'] = data['name'];
      if (data['city'] != null) storedUser['city'] = data['city'];
      if (data['region'] != null) storedUser['region'] = data['region'];
      storage.write('user', storedUser);
      Get.snackbar(
        'Success',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return true;
    }
    Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<void> fetchJobs({bool refresh = false}) async {
    try {
      if (refresh) {
        jobs.clear();
        _jobsPage = 1;
      }
      jobsLoading.value = true;
      final res = await _service.getJobs(page: _jobsPage);
      jobsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list =
            (raw is Map ? (raw['data'] ?? raw['jobs'] ?? []) : raw) as List?;
        if (list != null) {
          jobs.addAll(list);
          _jobsPage++;
        }
      } else {
        if (refresh) {
          Get.snackbar(
            'Error',
            res.message ?? 'Failed to load jobs',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
          );
        }
      }
    } catch (e) {
      jobsLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<bool> acceptJob(int jobId) async {
    try {
      final res = await _service.acceptJob(jobId);
      if (res.success) {
        await fetchJobs(refresh: true);
        await fetchMyJobs(refresh: true);
        Get.snackbar(
          'Accepted',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to accept job',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<bool> startJob(int jobId) async {
    try {
      final res = await _service.startJob(jobId);
      if (res.success) {
        await fetchMyJobs(refresh: true);
        Get.snackbar(
          'Started',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to start job',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<bool> completeJob(int jobId) async {
    try {
      final res = await _service.completeJob(jobId);
      if (res.success) {
        await fetchMyJobs(refresh: true);
        await fetchDashboard();
        Get.snackbar(
          'Completed!',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to complete job',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<void> confirmPaymentReceived(int jobId) async {
    try {
      final res = await _service.confirmPaymentReceived(jobId);
      if (res.success) {
        await fetchMyJobs();
        Get.snackbar(
          'Done',
          'Payment confirmed as received',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchMyJobs({bool refresh = false}) async {
    try {
      if (refresh) {
        myJobs.clear();
        _myJobsPage = 1;
      }
      myJobsLoading.value = true;
      final res = await _service.getMyJobs(page: _myJobsPage);
      myJobsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list =
            (raw is Map ? (raw['data'] ?? raw['jobs'] ?? []) : raw) as List?;
        if (list != null) {
          myJobs.addAll(list);
          _myJobsPage++;
        }
      } else {
        if (refresh) {
          Get.snackbar(
            'Error',
            res.message ?? 'Failed to load my jobs',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
          );
        }
      }
    } catch (e) {
      myJobsLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchNotifications() async {
    try {
      notificationsLoading.value = true;
      final res = await _service.getNotifications();
      notificationsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list = (raw is Map ? (raw['data'] ?? []) : raw) as List?;
        if (list != null) notifications.value = list;
      }
    } catch (e) {
      notificationsLoading.value = false;
    }
  }

  Future<void> fetchWallet() async {
    try {
      walletLoading.value = true;
      final res = await _service.getWallet();
      walletLoading.value = false;
      if (res.success && res.data != null) {
        walletData.value = Map<String, dynamic>.from(res.data as Map);
        final txList =
            res.data['recent_transactions'] ?? res.data['transactions'] ?? [];
        if (txList is List) transactions.value = txList;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load wallet',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
      await fetchPaymentMethods();
    } catch (e) {
      walletLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<bool> withdraw(int paymentMethodId, double amount) async {
    try {
      final res = await _service.withdraw(paymentMethodId, amount);
      if (res.success) {
        await fetchWallet();
        Get.snackbar(
          'Withdrawn',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to withdraw',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final res = await _service.getPaymentMethods();
      if (res.success && res.data != null) {
        final raw = res.data;
        final list = raw is List
            ? raw
            : (raw is Map ? (raw['data'] ?? []) : []);
        paymentMethods.value = list as List;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payment methods',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<Map?> fetchKycStatus() async {
    try {
      final res = await _service.getKycStatus();
      if (res.success && res.data != null) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load KYC status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return null;
    }
  }

  Future<bool> submitKyc({
    required String cnicNumber,
    required XFile cnicFront,
    required XFile cnicBack,
  }) async {
    try {
      final res = await _service.submitKyc(
        cnicNumber: cnicNumber,
        cnicFront: cnicFront,
        cnicBack: cnicBack,
      );
      if (res.success) {
        Get.snackbar(
          'Submitted',
          res.message ?? 'KYC submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to submit KYC',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(XFile image) async {
    try {
      final res = await _service.uploadProfilePhoto(image);
      if (res.success) {
        final photoUrl = res.data?['photo_url'];
        // Update profile photo in userProfile, dashboardData and GetStorage
        if (photoUrl != null) {
          if (userProfile.isNotEmpty) {
            final current = Map<String, dynamic>.from(userProfile);
            final user = Map<String, dynamic>.from(current['user'] ?? {});
            user['profile_photo'] = photoUrl;
            current['user'] = user;
            userProfile.value = current;
          }
          final dash = Map<String, dynamic>.from(dashboardData);
          final dashUser = Map<String, dynamic>.from(dash['user'] ?? {});
          dashUser['profile_photo'] = photoUrl;
          dash['user'] = dashUser;
          dashboardData.value = dash;
          final storage = GetStorage();
          final storedUser = storage.read('user') ?? {};
          storedUser['profile_photo'] = photoUrl;
          storage.write('user', storedUser);
        }
        Get.snackbar(
          'Updated',
          'Profile photo updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to upload photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<bool> setDefaultPaymentMethod(int paymentMethodId) async {
    try {
      final res = await _service.setDefaultPaymentMethod(paymentMethodId);
      if (res.success) {
        await fetchPaymentMethods();
        Get.snackbar(
          'Updated',
          'Default payment method updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to update payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<bool> addPaymentMethod({
    required String type,
    required String accountName,
    required String accountNumber,
    String? ibanNumber,
  }) async {
    try {
      final res = await _service.addPaymentMethod(
        type: type,
        accountName: accountName,
        accountNumber: accountNumber,
        ibanNumber: ibanNumber,
      );
      if (res.success) {
        await fetchPaymentMethods();
        Get.snackbar(
          'Added',
          res.message ?? 'Payment method added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to add payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<void> fetchPrograms({bool refresh = false}) async {
    try {
      if (refresh) programs.clear();
      programsLoading.value = true;
      final res = await _service.getPrograms();
      programsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list =
            (raw is Map ? (raw['data'] ?? raw['programs'] ?? []) : raw)
                as List?;
        if (list != null) programs.value = list;
      } else {
        if (refresh) {
          Get.snackbar(
            'Error',
            res.message ?? 'Failed to load programs',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
          );
        }
      }
    } catch (e) {
      programsLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<bool> enrollInProgram(int programId, {required int productId}) async {
    try {
      final res = await _service.enrollInProgram(
        programId,
        productId: productId,
      );
      if (res.success) {
        await fetchPrograms(refresh: true);
        Get.snackbar(
          'Enrolled',
          res.message ?? 'Successfully enrolled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to enroll',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }

  Future<void> fetchNearbyShops({double? latitude, double? longitude}) async {
    try {
      shopsLoading.value = true;
      // Pass 5000 km radius so all shops in Pakistan are returned (map shows all)
      final res = await _service.getNearbyShops(
        latitude: latitude,
        longitude: longitude,
        radius: 5000,
      );
      shopsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list =
            (raw is Map ? (raw['data'] ?? raw['shops'] ?? []) : raw) as List?;
        if (list != null) nearbyShops.value = list;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load nearby shops',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      shopsLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchProductClaims({String? status, int? programId}) async {
    try {
      claimsLoading.value = true;
      final res = await _service.getProductClaims(
        status: status,
        programId: programId,
      );
      claimsLoading.value = false;
      if (res.success && res.data != null) {
        final raw = res.data;
        final list = (raw is Map ? (raw['data'] ?? []) : raw) as List?;
        if (list != null) productClaims.value = list;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load claims',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      claimsLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<void> fetchEnrolledPrograms() async {
    try {
      final res = await _service.getEnrolledPrograms();
      if (res.success && res.data != null) {
        final raw = res.data;
        final list = (raw is Map ? (raw['data'] ?? []) : raw) as List?;
        if (list != null) enrolledPrograms.value = list;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to load programs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
    }
  }

  Future<bool> submitProductClaim({
    required int programId,
    required int productId,
    required Uint8List imageBytes,
  }) async {
    try {
      isLoading.value = true;
      final res = await _service.submitProductClaim(
        programId: programId,
        productId: productId,
        imageBytes: imageBytes,
      );
      isLoading.value = false;
      if (res.success) {
        Get.snackbar(
          'Success',
          res.message ?? 'Claim submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        await fetchProductClaims();
        return true;
      }
      Get.snackbar(
        'Error',
        res.message ?? 'Failed to submit claim',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
      );
      return false;
    }
  }
}
