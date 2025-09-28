import 'package:flutter/material.dart';
import '../../models/vendor.dart';

class VendorNotificationScreen extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorNotificationScreen({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications Screen Placeholder')),
    );
  }
}
