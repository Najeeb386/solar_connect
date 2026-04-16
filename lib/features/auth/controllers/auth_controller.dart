import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/login.dart';
import '../screens/signup.dart';
import '../screens/otp_check.dart';
import '../screens/forget_password.dart';
import '../../installer/dashboard.dart';
import '../../installer/controllers/installer_controller.dart';
import '../../brand/dashboard.dart';
import '../../brand/controllers/brand_controller.dart';
import '../../shopkeeper/dashboard.dart';
import '../../shopkeeper/controllers/shopkeeper_controller.dart';
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
      email: emailController.text,
      password: passwordController.text,
    );
    isLoading.value = false;

    if (response.success) {
      Get.snackbar(
        'Success',
        'Login Successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      if (selectedRole.value == 0) {
        Get.put(InstallerController());
        Get.offAll(() => const InstallerDashboard());
      } else if (selectedRole.value == 1) {
        Get.put(BrandController());
        Get.offAll(() => const BrandDashboard());
      } else if (selectedRole.value == 2) {
        Get.put(ShopkeeperController());
        Get.offAll(() => const ShopkeeperDashboard());
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
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      role: roleStr,
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );
    isLoading.value = false;

    if (response.success) {
      Get.snackbar(
        'Success',
        'Registration successful! Please wait for admin approval.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      Get.offAll(() => const LoginPage());
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

  // Verify OTP method
  void verifyOTP() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
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
      backgroundColor: Colors.green.withOpacity(0.8),
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
  void resetPassword() async {
    if (forgotPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email or contact number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
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
      'OTP sent to your email/phone!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    // Navigate to OTP screen
    Get.to(() => const OTPCheckPage());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    forgotPasswordController.dispose();
    super.onClose();
  }
}
