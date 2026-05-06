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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFF3E0),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 40,
                      color: Color(0xFFFF8F00),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Role Selector
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRoleChip(
                          "Installer",
                          0,
                          authController.selectedRole.value,
                          authController,
                        ),
                        const SizedBox(width: 8),
                        _buildRoleChip(
                          "Brand",
                          1,
                          authController.selectedRole.value,
                          authController,
                        ),
                        const SizedBox(width: 8),
                        _buildRoleChip(
                          "Shopkeeper",
                          2,
                          authController.selectedRole.value,
                          authController,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Company Name (for Brand/Shopkeeper)
                Obx(() {
                  if (authController.selectedRole.value != 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your company name",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          "Company Name",
                          Icons.business,
                          authController.companyNameController,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Personal Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Full Name
                _buildTextField(
                  "Full Name",
                  Icons.person_outline,
                  authController.nameController,
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  "Email Address",
                  Icons.email_outlined,
                  authController.emailController,
                ),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(
                  "Phone Number",
                  Icons.phone_outlined,
                  authController.phoneController,
                ),
                const SizedBox(height: 16),

                // Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Security",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => _buildTextField(
                    "Password",
                    Icons.lock_outline,
                    authController.passwordController,
                    !authController.isPasswordVisible.value,
                    "Min 8 characters",
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                Obx(
                  () => _buildTextField(
                    "Confirm Password",
                    Icons.lock_outline,
                    authController.confirmPasswordController,
                    !authController.isPasswordVisible.value,
                    "Repeat password",
                  ),
                ),

                const SizedBox(height: 12),

                // Show/Hide Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => authController.togglePasswordVisibility(),
                    child: Obx(
                      () => Text(
                        authController.isPasswordVisible.value
                            ? "Hide Password"
                            : "Show Password",
                        style: const TextStyle(
                          color: Color(0xFFFF8F00),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => authController.signup(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(
                          0xFFFF8F00,
                        ).withValues(alpha: 0.6),
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
                              "Create My Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account
                GestureDetector(
                  onTap: () => authController.navigateToLogin(),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                        children: const [
                          TextSpan(
                            text: "Sign in here",
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

                const SizedBox(height: 16),

                // Terms text
                Center(
                  child: Text(
                    "By registering you agree to our Terms of Service and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(
    String label,
    int role,
    int selected,
    AuthController controller,
  ) {
    final isSelected = selected == role;
    Color chipColor = const Color(0xFFFF8F00);

    if (role == 1) chipColor = const Color(0xFF2196F3); // Brand - Blue
    if (role == 2) chipColor = const Color(0xFF9C27B0); // Shopkeeper - Purple

    return GestureDetector(
      onTap: () => controller.selectRole(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, [
    bool isObscure = false,
    String? helperText,
  ]) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        helperText: helperText,
        helperStyle: TextStyle(fontSize: 11, color: Colors.grey),
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
