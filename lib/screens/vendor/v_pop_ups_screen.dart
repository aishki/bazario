import 'package:flutter/material.dart';
import '../../models/vendor.dart';

class VendorPopUps extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorPopUps({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pop Ups')),
      body: const Center(child: Text('Pop Ups Screen Placeholder')),
    );
  }
}
