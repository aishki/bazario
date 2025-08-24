import 'package:flutter/material.dart';

class VendorDashboard extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;

  const VendorDashboard({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$businessName Dashboard'),
        actions: [
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
              'Welcome to your $businessName dashboard!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text('Manage your products and profile'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product management coming soon'),
                  ),
                );
              },
              child: const Text('Manage Products'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event applications coming soon'),
                  ),
                );
              },
              child: const Text('Apply to Events'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document management coming soon'),
                  ),
                );
              },
              child: const Text('Manage Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
