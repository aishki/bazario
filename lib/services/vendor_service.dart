import 'api_service.dart';
import '../models/vendor.dart';
import '../models/user.dart';
import '../models/vendor_product.dart';

class VendorService {
  final ApiService _apiService = ApiService();

  Future<List<Vendor>> getVendors() async {
    final response = await _apiService.get('vendors.php');
    if (response['success'] == true && response['vendors'] != null) {
      return (response['vendors'] as List)
          .map((vendorJson) => Vendor.fromJson(vendorJson))
          .toList();
    }
    return [];
  }

  Future<Vendor?> getVendorProfile(String vendorId) async {
    final response = await _apiService.get('vendors.php?vendor_id=$vendorId');
    if (response['success'] == true && response['vendor'] != null) {
      return Vendor.fromJson(response['vendor']);
    }
    return null;
  }

  Future<bool> updateVendorProfile(Vendor vendor) async {
    try {
      print('[v0] Updating vendor profile for: ${vendor.id}');
      print('[v0] Vendor data: ${vendor.toJson()}');
      final response = await _apiService.put('vendors.php', vendor.toJson());
      print('[v0] API response: $response');
      return response['success'] == true;
    } catch (e) {
      print('[v0] Error updating vendor profile: $e');
      return false;
    }
  }

  Future<Vendor?> getCurrentVendorProfile() async {
    // This would typically get the current user's ID from auth service
    // For now, we'll need to pass the vendor ID from the calling widget
    return null; // To be implemented with proper auth integration
  }

  Future<List<VendorProduct>> getTopProducts(String vendorId) async {
    final response = await _apiService.get(
      'vendor_products.php?vendor_id=$vendorId',
    );
    if (response['success'] == true && response['products'] != null) {
      return (response['products'] as List)
          .map((p) => VendorProduct.fromJson(p))
          .toList();
    }
    return [];
  }

  Future<bool> updateTopProducts(VendorProduct product) async {
    try {
      print('[v0] Updating product: ${product.id}');
      print('[v0] Data: ${product.toJson()}');
      final response = await _apiService.put(
        'vendor_products.php',
        product.toJson(),
      );
      print('[v0] API response: $response');
      return response['success'] == true;
    } catch (e) {
      print('[v0] Error updating product: $e');
      return false;
    }
  }
}
