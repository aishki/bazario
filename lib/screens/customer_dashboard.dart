import 'package:flutter/material.dart';
import 'login_screen.dart';

class CustomerDashboard extends StatelessWidget {
  final String? userId;
  final String? email;
  final bool isBrowseMode;

  const CustomerDashboard({
    super.key,
    this.userId,
    this.email,
    this.isBrowseMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isBrowseMode ? 'Browse Bazario' : 'Customer Dashboard'),
        actions: [
          if (isBrowseMode)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: Color(0xFF74CC00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/welcome');
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBrowseMode
                  ? 'Welcome to Bazario!\nExplore The Neighbor Goods'
                  : 'Welcome to Bazario, ${email ?? 'Customer'}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isBrowseMode)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  border: Border.all(color: const Color(0xFFFF9E17)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You\'re in browse mode. Log in to interact with products and events.',
                  style: TextStyle(color: Color(0xFF856404), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              )
            else
              const Text('Browse products and events from The Neighbor Goods'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (isBrowseMode) {
                  _showBrowseModeDialog(context, 'Events');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Events feature coming soon')),
                  );
                }
              },
              child: const Text('Browse Events'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isBrowseMode) {
                  _showBrowseModeDialog(context, 'Products');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Products feature coming soon'),
                    ),
                  );
                }
              },
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBrowseModeDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log In Required'),
          content: Text(
            'Please log in to access $feature and interact with The Neighbor Goods.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74CC00),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
