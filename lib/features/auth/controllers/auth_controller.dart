import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/login.dart';
import '../screens/signup.dart';
import '../screens/otp_check.dart';
import '../screens/forget_password.dart';
import 'package:solar_partner/core/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final companyNameController = TextEditingController();
  final otpController = TextEditingController();
  final forgotPasswordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final selectedRole = 0.obs; // 0 = Installer, 1 = Brand, 2 = Shopkeeper

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectRole(int role) {
    selectedRole.value = role;
  }

  // Login method
  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final response = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    isLoading.value = false;

    if (response.success) {
      final userData = response.data['user'];
      if (userData == null) {
        Get.snackbar(
          'Error',
          'Invalid response from server',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final userRole = (userData['role']?.toString() ?? 'installer')
          .toLowerCase()
          .trim();
      final userName = userData['name']?.toString() ?? 'User';

      Get.snackbar(
        'Success',
        'Welcome $userName!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      if (userRole == 'brand') {
        Get.offAllNamed('/brand-dashboard');
      } else if (userRole == 'shopkeeper') {
        Get.offAllNamed('/shopkeeper-dashboard');
      } else {
        Get.offAllNamed('/installer-dashboard');
      }
    } else {
      Get.snackbar(
        'Error',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // Signup method
  void signup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Add company name validation for Brand/Shopkeeper
    if (selectedRole.value != 0 && companyNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Company name is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    String roleStr = selectedRole.value == 0
        ? 'installer'
        : selectedRole.value == 1
        ? 'brand'
        : 'shopkeeper';

    isLoading.value = true;
    final response = await _authService.register(
      name: (roleStr == 'brand' || roleStr == 'shopkeeper')
          ? companyNameController.text.trim()
          : nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      role: roleStr,
      password: passwordController.text.trim(),
      passwordConfirmation: confirmPasswordController.text.trim(),
    );
    isLoading.value = false;

    if (response.success) {
      final userData = response.data['user'];
      if (userData == null) {
        Get.snackbar(
          'Error',
          'Invalid response from server',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final rawRole = userData['role']?.toString() ?? 'installer';
      final userRole = rawRole.toLowerCase().trim();
      final userName = userData['name']?.toString() ?? 'User';

      Get.snackbar(
        'Success',
        'Welcome $userName!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      switch (userRole) {
        case 'installer':
          Get.offAllNamed('/installer-dashboard');
          break;
        case 'brand':
          Get.offAllNamed('/brand-dashboard');
          break;
        case 'shopkeeper':
          Get.offAllNamed('/shopkeeper-dashboard');
          break;
        default:
          Get.offAllNamed('/installer-dashboard');
      }
    } else {
      // Show error from server (validation, duplicate email, etc.)
      Get.snackbar(
        'Registration Failed',
        response.message.isNotEmpty ? response.message : 'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Verify OTP method
  void verifyOTP() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Account Verified Successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );

    // Navigate to login
    Get.offAll(() => const LoginPage());
  }

  // Navigate to Signup
  void navigateToSignup() {
    Get.to(() => const SignUpPage());
  }

  // Navigate to Login
  void navigateToLogin() {
    Get.back();
  }

  // Navigate to Forgot Password
  void navigateToForgotPassword() {
    Get.to(() => const ForgetPasswordPage());
  }

  // Reset Password method
  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    // Note: OTP/forgot password API not yet on backend, show friendly message
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.snackbar(
      'Email Sent',
      'If this email is registered, you will receive reset instructions.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
    Get.to(() => const OTPCheckPage());
  }

  void logout() async {
    isLoading.value = true;
    await _authService.logout();
    isLoading.value = false;

    emailController.clear();
    passwordController.clear();

    Get.offAll(() => const LoginPage());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    companyNameController.dispose();
    otpController.dispose();
    forgotPasswordController.dispose();
    super.onClose();
  }
}
