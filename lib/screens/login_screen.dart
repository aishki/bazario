import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import 'customer/c_dashboard.dart';
import '../components/vendor_navbar.dart';
import '../models/vendor.dart';
import '../models/vendor_contact.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://bazario-backend-aszl.onrender.com/api/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'login',
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on role
            if (responseData['role'] == 'vendor') {
              final vendor = Vendor(
                id: responseData['vendor_id'] ?? responseData['id'] ?? '',
                businessName: responseData['business_name'] ?? 'Unknown',
                description: responseData['description'],
                businessCategory: responseData['business_category'],
                logoUrl: responseData['logo_url'],
                verified:
                    responseData['verified'] == true ||
                    responseData['verified'] == 1,
                socialLinks: SocialLinks.fromJson(
                  responseData['social_links'] ?? {},
                ),
                createdAt:
                    DateTime.tryParse(responseData['created_at'] ?? '') ??
                    DateTime.now(),
                contact: responseData['contact_info'] != null
                    ? VendorContact.fromJson(responseData['contact_info'])
                    : null,
                contactDisplayPreferences: ContactDisplayPreferences.fromJson(
                  responseData['contact_display_preferences'] ?? {},
                ),
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VendorNavBar(
                    userId: responseData['user_id'],
                    vendorId: responseData['vendor_id'],
                    businessName:
                        responseData['business_name'] ?? 'My Business',
                    vendor: vendor,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CustomerDashboard(
                    userId: responseData['user_id'],
                    email: responseData['email'],
                  ),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? 'Login failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          String errorMessage = 'Login failed';
          if (response.statusCode == 401) {
            errorMessage = 'Invalid email or password';
          } else if (response.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (error) {
      print('[v0] Network error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection error. Please check your internet and try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final whiteCardWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/login-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: whiteCardWidth,
                    padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFFF9E17),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Maayong\nAdlaw!",
                              style: TextStyle(
                                fontFamily: 'Starla',
                                fontSize: 35,
                                height: 1.2,
                                color: Color(0xFF74CC00),
                              ),
                            ),
                            Image.asset(
                              'lib/assets/images/flower.png',
                              height: 100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 35,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        SizedBox(
                          height: 35,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              filled: true,
                              fillColor: const Color(0xFFDBFFAC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Forgot password feature coming soon',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Color(0xFF276700),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: whiteCardWidth * 0.4,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF74CC00),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Log-in',
                                    style: TextStyle(
                                      fontFamily: 'Bagel Fat One',
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Color(0xFF569109),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: Color(0xFFB8700B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: -50,
                    left: -10,
                    right: -10,
                    child: Container(
                      height: 100,
                      width: whiteCardWidth + 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD800),
                        border: Border.all(
                          color: const Color(0xFFFF9E17),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          'lib/assets/images/w-bazario-logo.png',
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              'lib/assets/images/basket.png',
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
