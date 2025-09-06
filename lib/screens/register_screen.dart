import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Vendor fields
  final _positionController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

  String? _selectedRole = "Customer";
  String? _selectedCategory;

  bool _showPassword = false;
  bool _showRetypePassword = false;

  final List<String> _categories = [
    "Food & Beverage",
    "Fashion",
    "Technology",
    "Services",
    "Other",
  ];

  String? _errorMessage;
  bool _isLoading = false;

  // ✅ Personal Info + Vendor TextField builder
  Widget _buildFloatingTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPersonalInfo = false,
    TextInputType keyboardType = TextInputType.text,
    Color? fillColor,
  }) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: isPersonalInfo ? const Color(0xFF74CC00) : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: isPersonalInfo ? const Color(0xFF74CC00) : Colors.black54,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: isPersonalInfo
                ? const Color(0xFF74CC00).withOpacity(0.6)
                : Colors.black54,
          ),
          filled: true,
          fillColor:
              fillColor ??
              (isPersonalInfo ? Colors.white : const Color(0xFFDBFFAC)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: isPersonalInfo
                  ? const Color(0xFF276700)
                  : Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: isPersonalInfo
                  ? const Color(0xFF276700)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Username & Password builder with external label
  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF276700),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.black54,
              ),
              filled: true,
              fillColor: const Color(0xFFDBFFAC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (controller == _passwordController) {
                            _showPassword = !_showPassword;
                          } else {
                            _showRetypePassword = !_showRetypePassword;
                          }
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _greenDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 2,
      color: const Color(0xFF74CC00),
    );
  }

  // ✅ Registration function
  void _registerUser() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_passwordController.text != _retypePasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match";
        _isLoading = false;
      });
      return;
    }

    if (_usernameController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields";
        _isLoading = false;
      });
      return;
    }

    try {
      print("[v0] Starting registration request...");
      print("[v0] API URL: https://aishki.helioho.st/php_backend/api/auth.php");

      final response = await http
          .post(
            Uri.parse('https://aishki.helioho.st/php_backend/api/auth.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              "action": "register",
              "username": _usernameController.text.trim(),
              "email": _emailController.text.trim(),
              "password": _passwordController.text.trim(),
              "first_name": _firstNameController.text.trim(),
              "middle_name": _middleNameController.text.trim(),
              "last_name": _lastNameController.text.trim(),
              "suffix": _suffixController.text.trim().isNotEmpty
                  ? _suffixController.text.trim()
                  : null, // ✅ now sending suffix
              "phone": _phoneController.text.trim(),
              "role": _selectedRole?.toLowerCase(),
              "position": _selectedRole == "Vendor"
                  ? (_positionController.text.trim().isNotEmpty
                        ? _positionController.text.trim()
                        : "Owner")
                  : null,
              "business_name": _selectedRole == "Vendor"
                  ? (_businessNameController.text.trim().isNotEmpty
                        ? _businessNameController.text.trim()
                        : "New Business")
                  : null,
              "business_category": _selectedRole == "Vendor"
                  ? _selectedCategory
                  : null,
              "business_description": _selectedRole == "Vendor"
                  ? (_businessDescriptionController.text.trim().isNotEmpty
                        ? _businessDescriptionController.text.trim()
                        : null)
                  : null,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - server took too long to respond',
              );
            },
          );

      print("[v0] Response status: ${response.statusCode}");
      print("[v0] Response headers: ${response.headers}");
      print("[v0] Raw response body: ${response.body}");

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage =
              "Server error (${response.statusCode}). Please try again later.";
          _isLoading = false;
        });
        return;
      }

      if (response.body.trim().startsWith('<') ||
          response.body.contains('<br />')) {
        print("[v0] Server returned HTML instead of JSON");
        setState(() {
          _errorMessage =
              "Server configuration error. The PHP script may not be working properly. Response: ${response.body.substring(0, 200)}...";
          _isLoading = false;
        });
        return;
      }

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ??
                    "Registration successful! Please log in.",
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? "Registration failed";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("[v0] Registration error: $e");
      setState(() {
        if (e.toString().contains('timeout')) {
          _errorMessage =
              "Request timeout. Please check your internet connection and try again.";
        } else if (e.toString().contains('SocketException')) {
          _errorMessage =
              "Cannot connect to server. Please check your internet connection.";
        } else if (e.toString().contains('FormatException')) {
          _errorMessage =
              "Server returned invalid response. The PHP script may have errors.";
        } else {
          _errorMessage = "Network error: ${e.toString()}";
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final whiteCardWidth = MediaQuery.of(context).size.width * 0.85;
    final whiteCardHeight = MediaQuery.of(context).size.height * 0.85;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "lib/assets/images/signup-bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: whiteCardWidth,
              height: whiteCardHeight,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.85),
                border: Border.all(color: const Color(0xFF74CC00), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // ✅ Back Button in top-left
                  Positioned(
                    top: 0,
                    left: -15,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromRGBO(39, 103, 0, .8),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // go back to Login screen
                      },
                    ),
                  ),
                  Column(
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            "lib/assets/images/bazario-logo.png",
                            height: 60,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Be part of the neighborgoods!",
                            style: TextStyle(
                              fontFamily: "Starla",
                              fontSize: 16,
                              color: Color(0xFF74CC00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ✅ Username & Password with external labels
                              _buildLabeledField(
                                label: "Username",
                                hint: "e.g. john_doe",
                                controller: _usernameController,
                              ),
                              const SizedBox(height: 8),
                              _buildLabeledField(
                                label: "Password",
                                hint: "Enter your password",
                                controller: _passwordController,
                                obscure: !_showPassword,
                                isPassword: true,
                              ),
                              const SizedBox(height: 8),
                              _buildLabeledField(
                                label: "Retype Password",
                                hint: "Re-enter your password",
                                controller: _retypePasswordController,
                                obscure: !_showRetypePassword,
                                isPassword: true,
                              ),

                              _greenDivider(),
                              const Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontFamily: 'Poppins-Medium',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF276700),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFloatingTextField(
                                      label: "First Name",
                                      hint: "e.g. John",
                                      controller: _firstNameController,
                                      isPersonalInfo: true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildFloatingTextField(
                                      label: "Middle Name",
                                      hint: "e.g. William",
                                      controller: _middleNameController,
                                      isPersonalInfo: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFloatingTextField(
                                      label: "Last Name",
                                      hint: "e.g. Smith",
                                      controller: _lastNameController,
                                      isPersonalInfo: true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildFloatingTextField(
                                      label: "Suffix",
                                      hint: "e.g. Jr.",
                                      controller: _suffixController,
                                      isPersonalInfo: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildFloatingTextField(
                                label: "Phone Number",
                                hint: "e.g. +639123456789",
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                isPersonalInfo: true,
                              ),
                              const SizedBox(height: 8),
                              _buildFloatingTextField(
                                label: "Email",
                                hint: "e.g. john@example.com",
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                isPersonalInfo: true,
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                "Role",
                                style: TextStyle(
                                  fontFamily: 'Poppins-Medium',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF276700),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      title: const Text(
                                        "Customer",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: "Customer",
                                      groupValue: _selectedRole,
                                      onChanged: (val) =>
                                          setState(() => _selectedRole = val),
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                      title: const Text(
                                        "Vendor",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: "Vendor",
                                      groupValue: _selectedRole,
                                      onChanged: (val) =>
                                          setState(() => _selectedRole = val),
                                    ),
                                  ),
                                ],
                              ),

                              if (_selectedRole == "Vendor") ...[
                                _greenDivider(),
                                const Center(
                                  child: Text(
                                    "About Your Business",
                                    style: TextStyle(
                                      fontFamily: 'Starla',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF74CC00),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFloatingTextField(
                                        label: "Business Name",
                                        hint: "e.g. John's Café",
                                        controller: _businessNameController,
                                        fillColor: const Color(
                                          0xFFFFF4BA,
                                        ), // ✅ special color
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildFloatingTextField(
                                        label: "Position",
                                        hint: "e.g. Owner",
                                        controller: _positionController,
                                        fillColor: const Color(0xFFFFF4BA),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 35,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    items: _categories
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Category",
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      filled: true,
                                      fillColor: const Color(0xFFDBFFAC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF276700),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    ),
                                    onChanged: (val) =>
                                        setState(() => _selectedCategory = val),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Color(0xFF276700),
                                    ),
                                    iconSize: 18,
                                    isDense: true,
                                    dropdownColor: const Color(0xFFDBFFAC),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildFloatingTextField(
                                  label: "Short Business Description",
                                  hint: "e.g. We sell organic coffee",
                                  controller: _businessDescriptionController,
                                ),
                              ],

                              const SizedBox(height: 20),

                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF74CC00),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _registerUser,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(
                                            fontFamily: 'Bagel Fat One',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
