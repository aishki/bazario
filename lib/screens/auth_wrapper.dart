import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'customer_dashboard.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    setState(() {
      _isLoggedIn = AuthService.isLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const CustomerDashboard();
    } else {
      return const WelcomeScreen();
    }
  }
}
