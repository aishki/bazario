import 'package:flutter/material.dart';
import '../../models/vendor.dart';

class VendorMyDocs extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorMyDocs({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Docs')),
      body: const Center(child: Text('My Docs Screen Placeholder')),
    );
  }
}
