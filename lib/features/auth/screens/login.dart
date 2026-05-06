import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_partner/features/auth/controllers/auth_controller.dart';
import 'signup.dart';
import 'api_config.dart';
import 'mock_api_test.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFF3E0),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 40,
                      color: Color(0xFFFF8F00),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    "Solar Partner",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    "Powering Solar Professionals",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                const SizedBox(height: 50),

                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                Text(
                  "Sign in to continue",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 30),

                _buildTextField(
                  "Email",
                  Icons.email_outlined,
                  authController.emailController,
                  false,
                ),

                const SizedBox(height: 20),

                Obx(
                  () => TextField(
                    controller: authController.passwordController,
                    obscureText: !authController.isPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () =>
                            authController.togglePasswordVisibility(),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => authController.navigateToForgotPassword(),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFFFF8F00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(
                          0xFFFF8F00,
                        ).withOpacity(0.6),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Get.to(() => const SignUpPage()),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                        children: const [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Color(0xFFFF8F00),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isObscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
