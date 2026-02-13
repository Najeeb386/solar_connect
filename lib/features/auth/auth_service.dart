import 'package:get/get.dart';

// Auth Service using GetX for state management
// This service handles authentication-related operations

class AuthService extends GetxService {
  // Observable user state
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;
  final userName = ''.obs;

  // Simulate login
  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any valid credentials
    if (email.isNotEmpty && password.length >= 6) {
      isLoggedIn.value = true;
      userEmail.value = email;
      return true;
    }
    return false;
  }

  // Simulate signup
  Future<bool> signup(String name, String email, String password, String phone) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any valid credentials
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6 && phone.isNotEmpty) {
      isLoggedIn.value = false;
      userName.value = name;
      userEmail.value = email;
      return true;
    }
    return false;
  }

  // Simulate OTP verification
  Future<bool> verifyOTP(String otp) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any 4-digit OTP
    if (otp.length == 4) {
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';
  }

  // Check if user is logged in
  bool isAuthenticated() {
    return isLoggedIn.value;
  }
}
