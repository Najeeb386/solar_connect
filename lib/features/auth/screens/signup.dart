import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo
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
                  "Solar Connect",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Powering Solar Professionals",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                "Welcome Onboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Join Our Family of Solar Experts Today!",
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 30),

              // Name
              _buildTextField("Full Name", Icons.person_outline, authController.nameController),

              const SizedBox(height: 20),

              // Email
              _buildTextField("Email", Icons.email_outlined, authController.emailController),

              const SizedBox(height: 20),

              // Phone No
              _buildTextField("Phone Number", Icons.phone_outlined, authController.phoneController),

              const SizedBox(height: 20),

              // Password
              Obx(() => _buildTextField(
                    "Password",
                    Icons.lock_outline,
                    authController.passwordController,
                    !authController.isPasswordVisible.value,
                  )),

              const SizedBox(height: 12),

              // Show/Hide Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => authController.togglePasswordVisibility(),
                  child: Obx(() => Text(
                        authController.isPasswordVisible.value ? "Hide Password" : "Show Password",
                        style: const TextStyle(
                          color: Color(0xFFFF8F00),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ),
              ),

              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.signup(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFFFF8F00).withOpacity(0.6),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ),

              const SizedBox(height: 30),

              // Sign In Link
              GestureDetector(
                onTap: () => authController.navigateToLogin(),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                      children: const [
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Color(0xFFFF8F00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

  }

  static Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller, [bool isObscure = false]) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
