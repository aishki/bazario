import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for input formatters char limit
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/gridicons.dart';
import 'dart:convert';
import 'dart:async'; // Import for Timer

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _registrationSuccess = false;
  String? _successMessage;

  // Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Track field focus
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _retypePasswordFocus = FocusNode();

  Timer? _usernameDebounce;
  Timer? _emailDebounce;
  Timer? _phoneDebounce;

  // Error messages for each field
  Map<String, String?> _fieldErrors = {
    "username": null,
    "email": null,
    "phone": null,
    "password": null,
    "retype_password": null,
  };
  Map<String, bool> _fieldValid = {
    "username": false,
    "email": false,
    "phone": false,
    "password": false,
    "retype_password": false,
  };

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

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _emailDebounce?.cancel();
    _phoneDebounce?.cancel();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _retypePasswordFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _fieldErrors["username"] = "Username is required";
        _fieldValid["username"] = false;
      });
      return;
    }

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(value);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        _fieldErrors["username"] = "Username is required";
        _fieldValid["username"] = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://bazario-backend-aszl.onrender.com/api/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_username", "username": username}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        setState(() {
          _fieldErrors["username"] =
              "This username isn't available. Please try another.";
          _fieldValid["username"] = false;
        });
      } else {
        setState(() {
          _fieldErrors["username"] = null;
          _fieldValid["username"] = true;
        });
      }
    } catch (_) {}
  }

  void _onEmailChanged(String value) {
    _emailDebounce?.cancel();

    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (value.isEmpty) {
      setState(() {
        _fieldErrors["email"] = "Email is required";
        _fieldValid["email"] = false;
      });
      return;
    }

    if (!emailRegex.hasMatch(value)) {
      setState(() {
        _fieldErrors["email"] = "Enter a valid email address.";
        _fieldValid["email"] = false;
      });
      return;
    }

    _emailDebounce = Timer(const Duration(milliseconds: 500), () {
      _checkEmailAvailability(value);
    });
  }

  Future<void> _checkEmailAvailability(String email) async {
    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _fieldErrors["email"] = "Enter a valid email address.";
        _fieldValid["email"] = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://bazario-backend-aszl.onrender.com/api/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_email", "email": email}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        setState(() {
          _fieldErrors["email"] =
              "This email isn't available. Please try another.";
          _fieldValid["email"] = false;
        });
      } else {
        setState(() {
          _fieldErrors["email"] = null;
          _fieldValid["email"] = true;
        });
      }
    } catch (_) {}
  }

  void _onPhoneChanged(String value) {
    _phoneDebounce?.cancel();

    if (value.isEmpty) {
      setState(() {
        _fieldErrors["phone"] = "Phone number is required";
        _fieldValid["phone"] = false;
      });
      return;
    }

    final phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");
    if (!phoneRegex.hasMatch(value)) {
      setState(() {
        _fieldErrors["phone"] = "Enter a valid phone number.";
        _fieldValid["phone"] = false;
      });
      return;
    }

    _phoneDebounce = Timer(const Duration(milliseconds: 500), () {
      _checkPhoneAvailability(value);
    });
  }

  Future<void> _checkPhoneAvailability(String phone) async {
    final phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _fieldErrors["phone"] = "Enter a valid phone number.";
        _fieldValid["phone"] = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://bazario-backend-aszl.onrender.com/api/auth.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": "check_phone", "phone": phone}),
      );

      final data = json.decode(response.body);
      if (data["status"] == "error") {
        setState(() {
          _fieldErrors["phone"] =
              "This phone number isn't available. Please try another.";
          _fieldValid["phone"] = false;
        });
      } else {
        setState(() {
          _fieldErrors["phone"] = null;
          _fieldValid["phone"] = true;
        });
      }
    } catch (_) {}
  }

  void _validateRetypePassword(String retypePassword) {
    if (retypePassword.isEmpty) {
      setState(() {
        _fieldErrors["retype_password"] = "Please retype your password.";
        _fieldValid["retype_password"] = false;
      });
      return;
    }

    if (retypePassword != _passwordController.text.trim()) {
      setState(() {
        _fieldErrors["retype_password"] = "Passwords do not match.";
        _fieldValid["retype_password"] = false;
      });
    } else {
      setState(() {
        _fieldErrors["retype_password"] = null;
        _fieldValid["retype_password"] = true;
      });
    }
  }

  void _validatePhone(String phone) {
    final phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _fieldErrors["phone"] = "Enter a valid phone number.";
        _fieldValid["phone"] = false;
      });
    } else {
      setState(() {
        _fieldErrors["phone"] = null;
        _fieldValid["phone"] = true;
      });
    }
  }

  void _validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 8) errors.add("at least 8 characters");
    if (!RegExp(r'[A-Z]').hasMatch(password)) errors.add("1 uppercase letter");
    if (!RegExp(r'[0-9]').hasMatch(password)) errors.add("1 number");
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password))
      errors.add("1 symbol");

    setState(() {
      if (errors.isEmpty) {
        _fieldErrors["password"] = null;
        _fieldValid["password"] = true;
      } else {
        _fieldErrors["password"] = "Password must have ${errors.join(", ")}.";
        _fieldValid["password"] = false;
      }
    });
  }

  Widget _buildFloatingTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPersonalInfo = false,
    TextInputType keyboardType = TextInputType.text,
    Color? fillColor,
    int? maxLines, // NEW: allows multi-line fields
    int? maxLength, // NEW: character limit (180)
    List<TextInputFormatter>? inputFormatters, // NEW: custom formatters
    double? height, // NEW: force a fixed height if desired
  }) {
    // If maxLength provided and no explicit inputFormatters, inject/use limiting formatter
    final List<TextInputFormatter>? effectiveFormatters =
        inputFormatters ??
        (maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null);

    final int effectiveMaxLines = maxLines ?? 1;

    final textField = TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: effectiveMaxLines,
      inputFormatters: effectiveFormatters,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: effectiveMaxLines > 1 ? 12 : 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isPersonalInfo
                ? const Color(0xFF276700)
                : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isPersonalInfo
                ? const Color(0xFF276700)
                : Colors.transparent,
          ),
        ),
        // show native counter if maxLength is set (you can hide with counterText: '')
        counterText: maxLength != null ? null : '',
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: textField);
    }

    // For single-line fields keep the original compact height
    if (effectiveMaxLines == 1) {
      return SizedBox(height: 35, child: textField);
    }

    // For multi-line fields return the TextField directly (it will size naturally)
    return textField;
  }

  // ✅ Username & Password builder with external label
  Widget _buildValidatedField({
    required String keyName,
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool obscure = false,
    bool isPassword = false,
    Function(String)? onChanged, // Use onChanged for debouncing
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
            focusNode: focusNode,
            obscureText: obscure,
            onChanged: onChanged, // Assign onChanged callback
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

              // Default: no border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),

              // Not focused: no border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),

              // Focused: dark green border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color(0xFF006400),
                  width: 2,
                ),
              ),

              // Error state: red border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),

              // Error + focused: red border still
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              suffixIcon: _fieldErrors[keyName] != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 6,
                      ), // 👈 add spacing
                      child: Iconify(Gridicons.cross_circle, color: Colors.red),
                    )
                  : (_fieldValid[keyName] == true
                        ? Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Iconify(
                              MaterialSymbols.check_circle,
                              color: Colors.green,
                            ),
                          )
                        : null),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
            ),
          ),
        ),
        if (_fieldErrors[keyName] != null) ...[
          const SizedBox(height: 2),
          Text(
            _fieldErrors[keyName]!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
        ],
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

    // Updated validation to include username and phone
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields";
        _isLoading = false;
      });
      return;
    }

    // Final check on all fields before sending
    _checkUsernameAvailability(_usernameController.text.trim());
    _checkEmailAvailability(_emailController.text.trim());
    _validatePhone(_phoneController.text.trim());
    _validatePassword(_passwordController.text.trim());
    _validateRetypePassword(_retypePasswordController.text.trim());

    // Check if any field is still invalid
    if (!_fieldValid["username"]! ||
        !_fieldValid["email"]! ||
        !_fieldValid["password"]! ||
        !_fieldValid["phone"]! ||
        !_fieldValid["retype_password"]!) {
      setState(() {
        _errorMessage = "Please fix the errors above.";
        _isLoading = false;
      });
      return;
    }

    try {
      print("[v0] Starting registration request...");
      print(
        "[v0] API URL: https://bazario-backend-aszl.onrender.com/api/auth.php",
      );

      final response = await http
          .post(
            Uri.parse('https://bazario-backend-aszl.onrender.com/api/auth.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              "action": "register",
              "username": _usernameController.text.trim(),
              "email": _emailController.text.trim(),
              "password": _passwordController.text.trim(),
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
        setState(() {
          _registrationSuccess = true;
          _successMessage =
              responseData['message'] ??
              "Registration successful! Please log in.";
          _isLoading = false;
        });
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
    final whiteCardHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "lib/assets/images/signup-bg.png",
              fit: BoxFit.cover,
            ),
          ),

          //Main Form Container
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
                  _registrationSuccess
                      ? _buildSuccessScreen(context) // ✅ Show success content
                      : _buildRegistrationForm(context), // ✅ Show form
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Image.asset("lib/assets/images/bazario-logo.png", height: 60),
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
                _buildValidatedField(
                  keyName: "username",
                  label: "Username",
                  hint: "e.g. john_doe",
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  onChanged: _onUsernameChanged,
                ),
                const SizedBox(height: 8),
                _buildValidatedField(
                  keyName: "email",
                  label: "Email",
                  hint: "e.g. john@example.com",
                  controller: _emailController,
                  focusNode: _emailFocus,
                  onChanged: _onEmailChanged,
                ),
                const SizedBox(height: 8),
                _buildValidatedField(
                  keyName: "password",
                  label: "Password",
                  hint: "Enter your password",
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscure: !_showPassword,
                  isPassword: true,
                  onChanged: _validatePassword,
                ),
                const SizedBox(height: 8),
                _buildValidatedField(
                  keyName: "retype_password",
                  label: "Retype Password",
                  hint: "Re-enter your password",
                  focusNode: _retypePasswordFocus,
                  controller: _retypePasswordController,
                  obscure: !_showRetypePassword,
                  isPassword: true,
                  onChanged: _validateRetypePassword,
                ),
                const SizedBox(height: 8),
                _buildValidatedField(
                  keyName: "phone",
                  label: "Phone Number",
                  hint: "e.g. +639123456789",
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  onChanged: _onPhoneChanged,
                ),

                // Removed old personal name fields
                // _greenDivider(),
                // const Text(
                //   "Full Name",
                //   style: TextStyle(
                //     fontFamily: 'Poppins-Medium',
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: Color(0xFF276700),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildFloatingTextField(
                //         label: "First Name",
                //         hint: "e.g. John",
                //         controller: _firstNameController,
                //         isPersonalInfo: true,
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       child: _buildFloatingTextField(
                //         label: "Last Name",
                //         hint: "e.g. Smith",
                //         controller: _lastNameController,
                //         isPersonalInfo: true,
                //       ),
                //     ),
                //   ],
                // ),
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
                        title: Transform.translate(
                          offset: const Offset(
                            -15,
                            0,
                          ), //move text closer to radio
                          child: const Text(
                            "Customer",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        value: "Customer",
                        groupValue: _selectedRole,
                        onChanged: (val) => setState(() => _selectedRole = val),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        title: Transform.translate(
                          offset: const Offset(
                            -15,
                            0,
                          ), // move text closer to radio
                          child: const Text(
                            "Vendor",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        value: "Vendor",
                        groupValue: _selectedRole,
                        onChanged: (val) => setState(() => _selectedRole = val),
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
                          fillColor: const Color(0xFFFFF4BA), // ✅ special color
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
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        filled: true,
                        fillColor: const Color(0xFFDBFFAC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFF276700),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
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
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(180)],
                  ),
                ],

                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
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

                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74CC00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Register",
                              style: TextStyle(
                                fontFamily: 'Bagel Fat One',
                                fontSize: 16,
                              ),
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
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text(
            _successMessage ?? "Registration successful!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF276700),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF74CC00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context); // go back to Login
            },
            child: const Text(
              "Go to Login",
              style: TextStyle(fontFamily: 'Bagel Fat One', fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
