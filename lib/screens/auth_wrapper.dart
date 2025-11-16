import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../components/customer_navbar.dart';
import '../components/vendor_navbar.dart';
import '../models/vendor.dart';
import '../models/vendor_contact.dart';
import '../models/customer.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final user = await AuthService().getUserSession();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user != null) {
      final role = _user!['role'];

      if (role == 'vendor') {
        final vendor = Vendor(
          id: _user!['vendor_id'] ?? '',
          businessName: _user!['business_name'] ?? 'My Business',
          description: '',
          businessCategory: '',
          logoUrl: '',
          verified: false,
          socialLinks: SocialLinks.empty(),
          createdAt: DateTime.now(),
          contact: VendorContact.empty(),
          contactDisplayPreferences: ContactDisplayPreferences.empty(),
        );

        return VendorNavBar(
          userId: _user!['id'],
          vendorId: _user!['vendor_id'],
          businessName: _user!['business_name'],
          vendor: vendor, // ✅ no more null
        );
      } else {
        final customer = Customer(
          id: _user!['id'],
          username: _user!['business_name'] ?? 'Guest',
          email: '',
          createdAt: DateTime.now(),
        );

        return CustomerNavBar(
          userId: _user!['id'],
          username: _user!['business_name'],
          customerId: _user!['id'],
          customer: customer, // ✅ no more null
        );
      }
    }

    return const WelcomeScreen();
  }
}
