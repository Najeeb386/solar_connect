import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class KYCPage extends StatefulWidget {
  const KYCPage({super.key});

  @override
  State<KYCPage> createState() => _KYCPageState();
}

class _KYCPageState extends State<KYCPage> {
  String? selectedDocumentType;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController documentNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  DateTime? selectedDate;

  final List<String> documentTypes = ['NIC (National Identity Card)', 'Passport'];

  @override
  void dispose() {
    fullNameController.dispose();
    documentNumberController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8F00),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "KYC Verification",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // Profile tap action
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Color(0xFFFF8F00),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Identity Verification",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Please verify your identity to continue",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Full Name
              const Text(
                "Full Name",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                "Enter your full name",
                Icons.person_outline,
                fullNameController,
              ),

              const SizedBox(height: 24),

              // Date of Birth
              const Text(
                "Date of Birth",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateOfBirthController,
                    decoration: InputDecoration(
                      hintText: "Select your date of birth",
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Document Type Selection
              const Text(
                "Select Document Type",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedDocumentType,
                  hint: const Text(
                    "Choose NIC or Passport",
                    style: TextStyle(color: Colors.grey),
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  ),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: documentTypes.map((String documentType) {
                    return DropdownMenuItem<String>(
                      value: documentType,
                      child: Row(
                        children: [
                          Icon(
                            documentType == 'NIC (National Identity Card)'
                                ? Icons.credit_card
                                : Icons.flight,
                            size: 20,
                            color: const Color(0xFFFF8F00),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            documentType,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDocumentType = newValue;
                      documentNumberController.clear();
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Document Number Input
              const Text(
                "Document Number",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                "Enter your document number",
                Icons.numbers,
                documentNumberController,
              ),

              const SizedBox(height: 12),

              // Hint text based on selection
              if (selectedDocumentType != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFFFF8F00),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedDocumentType == 'NIC (National Identity Card)'
                              ? "Enter your 13-digit NIC number (e.g., 1234567890123)"
                              : "Enter your passport number (e.g., AB1234567)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (fullNameController.text.trim().isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please enter your full name",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                      return;
                    }
                    if (selectedDate == null) {
                      Get.snackbar(
                        "Error",
                        "Please select your date of birth",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                      return;
                    }
                    if (selectedDocumentType == null) {
                      Get.snackbar(
                        "Error",
                        "Please select a document type",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                      return;
                    }
                    if (documentNumberController.text.trim().isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please enter your document number",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                      return;
                    }
                    // Proceed with KYC - navigate to success page
                    Get.offAllNamed('/verification-success');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 2),
        ),
      ),
    );
  }
}
