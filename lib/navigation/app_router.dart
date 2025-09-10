// app_router.dart
import 'package:flutter/material.dart';
import '../components/vendor_navbar.dart';
import '../models/vendor.dart';

class AppRouter {
  static Widget getVendorHome({
    required String userId,
    required Vendor vendor,
    required String vendorId,
    required String businessName,
  }) {
    return VendorNavBar(
      userId: userId,
      vendorId: vendorId,
      businessName: businessName,
      vendor: vendor,
    );
  }
}
