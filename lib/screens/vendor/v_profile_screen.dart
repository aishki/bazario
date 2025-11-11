import 'package:flutter/material.dart';
import '../../services/validation_service.dart';
import '../../services/availability_check_service.dart';
import '../../services/vendor_service.dart';
import '../../utils/debouncer.dart';
import '../../models/vendor.dart';
import '../../models/vendor_contact.dart';
import '../../services/auth_service.dart';
import 'v_my_shop_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  final String? userId;
  final String? vendorId;
  final Vendor vendor;

  const VendorProfileScreen({
    super.key,
    required this.vendor,
    this.userId,
    this.vendorId,
  });

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer();
  final _vendorService = VendorService();

  // Controllers
  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  late TextEditingController _positionController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _retypePasswordController =
      TextEditingController();

  Map<String, bool> _fieldValid = {
    'email': true,
    'phone': true,
    'username': true,
    'password': true,
    'retype_password': true,
  };

  String? _emailError;
  String? _phoneError;
  String? _usernameError;
  String? _passwordError;
  String? _retypePasswordError;

  bool _isSaving = false;
  bool _isCheckingEmail = false;
  bool _isCheckingPhone = false;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    super.initState();

    final contact = widget.vendor.contact;
    _firstNameController.text = contact?.firstName ?? '';
    _lastNameController.text = contact?.lastName ?? '';
    _positionController.text = contact?.position ?? '';
    _emailController.text = contact?.email ?? '';
    _phoneController.text = contact?.phoneNumber ?? '';
    _usernameController.text = '';
    _passwordController.text = '';
    _retypePasswordController.text = '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    _debouncer.run(() async {
      if (value.isEmpty) {
        setState(() {
          _emailError = null;
          _fieldValid['email'] = true;
        });
        return;
      }

      final formatError = ValidationService.validateEmailFormat(value);
      if (formatError != null) {
        setState(() {
          _emailError = formatError;
          _fieldValid['email'] = false;
        });
        return;
      }

      setState(() => _isCheckingEmail = true);

      final availabilityMessage =
          await AvailabilityCheckService.checkEmailAvailability(value);

      setState(() {
        _isCheckingEmail = false;
        if (availabilityMessage == null) {
          // Email is available ✅
          _emailError = null;
          _fieldValid['email'] = true;
        } else {
          // Email already taken ❌
          _emailError = availabilityMessage;
          _fieldValid['email'] = false;
        }
      });
    });
  }

  void _onPhoneChanged(String value) {
    _debouncer.run(() async {
      if (value.isEmpty) {
        setState(() {
          _phoneError = null;
          _fieldValid['phone'] = true;
        });
        return;
      }

      final formatError = ValidationService.validatePhoneFormat(value);
      if (formatError != null) {
        setState(() {
          _phoneError = formatError;
          _fieldValid['phone'] = false;
        });
        return;
      }

      setState(() => _isCheckingPhone = true);

      final availabilityMessage =
          await AvailabilityCheckService.checkPhoneAvailability(value);

      setState(() {
        _isCheckingPhone = false;
        if (availabilityMessage == null) {
          // ✅ Phone number is available
          _phoneError = null;
          _fieldValid['phone'] = true;
        } else {
          // ❌ Phone number already taken
          _phoneError = availabilityMessage;
          _fieldValid['phone'] = false;
        }
      });
    });
  }

  void _onUsernameChanged(String value) {
    _debouncer.run(() async {
      if (value.isEmpty) {
        setState(() {
          _usernameError = null;
          _fieldValid['username'] = true;
        });
        return;
      }

      final formatError = ValidationService.validateUsernameFormat(value);
      if (formatError != null) {
        setState(() {
          _usernameError = formatError;
          _fieldValid['username'] = false;
        });
        return;
      }

      setState(() => _isCheckingUsername = true);

      final availabilityMessage =
          await AvailabilityCheckService.checkUsernameAvailability(value);

      setState(() {
        _isCheckingUsername = false;
        if (availabilityMessage == null) {
          // ✅ Username is available
          _usernameError = null;
          _fieldValid['username'] = true;
        } else {
          // ❌ Username already taken
          _usernameError = availabilityMessage;
          _fieldValid['username'] = false;
        }
      });
    });
  }

  void _onPasswordChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordError = null;
        _fieldValid['password'] = true;
      });
      return;
    }

    final error = ValidationService.validatePasswordStrength(value);
    setState(() {
      _passwordError = error;
      _fieldValid['password'] = error == null;
    });
  }

  void _onRetypePasswordChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _retypePasswordError = null;
        _fieldValid['retype_password'] = true;
      });
      return;
    }

    if (value != _passwordController.text) {
      setState(() {
        _retypePasswordError = 'Passwords do not match';
        _fieldValid['retype_password'] = false;
      });
    } else {
      setState(() {
        _retypePasswordError = null;
        _fieldValid['retype_password'] = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedVendor = Vendor(
        id: widget.vendor.id,
        businessName: widget.vendor.businessName,
        description: widget.vendor.description,
        logoUrl: widget.vendor.logoUrl,
        socialLinks: widget.vendor.socialLinks,
        verified: widget.vendor.verified,
        businessCategory: widget.vendor.businessCategory,
        createdAt: widget.vendor.createdAt,
        contact: VendorContact(
          firstName: _firstNameController.text.isEmpty
              ? null
              : _firstNameController.text,
          lastName: _lastNameController.text.isEmpty
              ? null
              : _lastNameController.text,

          phoneNumber: _phoneController.text.isEmpty
              ? null
              : _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          position: _positionController.text.isEmpty
              ? null
              : _positionController.text,
        ),
      );

      bool success = await _vendorService.updateVendorProfile(updatedVendor);

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile saved successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to save profile. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final contact = vendor.contact;
    final welcomeText =
        contact?.position != null && contact!.position!.isNotEmpty
        ? "Welcome, ${contact.position}"
        : "Welcome, Vendor";

    return Scaffold(
      body: GestureDetector(
        onTap: _showComingSoonDialog,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 🌄 Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/vendor-profile-bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 🟢 Main Content (scrollable inside green box)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 0.9 * MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF74CC00).withOpacity(0.4),
                  border: Border.all(color: const Color(0xFF74CC00), width: 2),
                ),

                // 🌀 Only the content inside scrolls
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ⚪ 1️⃣ Contact Information Box
                          SizedBox(height: 24),

                          _buildWhiteBox(
                            title: "Contact Information",
                            children: [
                              _buildEditField(
                                "First Name",
                                _firstNameController,
                              ),
                              _buildEditField("Last Name", _lastNameController),
                              _buildEditField("Position", _positionController),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditField(
                                    "Email",
                                    _emailController,
                                    onChanged: _onEmailChanged,
                                  ),
                                  if (_emailError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _emailError!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditField(
                                    "Phone Number",
                                    _phoneController,
                                    onChanged: _onPhoneChanged,
                                  ),
                                  if (_phoneError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _phoneError!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          _buildWhiteBox(
                            title: "Account Details",
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditField(
                                    "Username",
                                    _usernameController,
                                    onChanged: _onUsernameChanged,
                                  ),
                                  if (_usernameError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _usernameError!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditField(
                                    "Password",
                                    _passwordController,
                                    isPassword: true,
                                    onChanged: _onPasswordChanged,
                                  ),
                                  if (_passwordError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _passwordError!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEditField(
                                    "Retype Password",
                                    _retypePasswordController,
                                    isPassword: true,
                                    onChanged: _onRetypePasswordChanged,
                                  ),
                                  if (_retypePasswordError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        _retypePasswordError!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // 🔸 Buttons (Stacked)
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9E17),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontFamily: 'Starla',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  await AuthService().logout();
                                  if (mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontFamily: 'Starla',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 🟣 Profile Header (fixed top)
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Container(
                height: 125,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      'lib/assets/images/vendor-profile-header-bg.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: const Color(0xFF74CC00), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFD400),
                                width: 3,
                              ),
                              image: DecorationImage(
                                image:
                                    vendor.logoUrl != null &&
                                        vendor.logoUrl!.isNotEmpty
                                    ? NetworkImage(vendor.logoUrl!)
                                    : const AssetImage(
                                            "lib/assets/images/default_profile.jpg",
                                          )
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 35),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                welcomeText,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: 'Starla',
                                  fontSize: 20,
                                  color: Color(0xFFD3EAB5),
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF365E00),
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VendorMyShop(
                                  vendor: vendor,
                                  userId: widget.userId ?? '',
                                  vendorId: widget.vendorId ?? '',
                                  businessName: vendor.businessName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9E17),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            minimumSize: const Size(70, 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "My Shop",
                            style: TextStyle(
                              fontFamily: 'Bagel Fat One',
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
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
    );
  }

  Widget _buildWhiteBox({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String value)? validator,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF74CC00),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF74CC00),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 3, // 👈 smaller height
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF276700),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF74CC00),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFFD400),
                  width: 1.4,
                ),
              ),
            ),
            validator: (value) {
              if (validator != null) {
                return validator(value ?? '');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFD400), width: 2),
          ),
          backgroundColor: const Color(0xFFFFF7E6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🚧 Feature in Progress",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF792401),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "This page is currently under development. We're working hard to bring you this feature soon!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xFF5A2401),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    "Got it!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Color(0xFF792401),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
