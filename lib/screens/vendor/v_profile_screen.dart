import 'package:flutter/material.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Profile')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Vendor profile will be implemented here')),
      ),
    );
  }
}
