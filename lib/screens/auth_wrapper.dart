import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome_screen.dart';
import 'customer_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // If user is logged in, show dashboard, otherwise show welcome screen
    if (session != null) {
      return const CustomerDashboard();
    } else {
      return const WelcomeScreen();
    }
  }
}
