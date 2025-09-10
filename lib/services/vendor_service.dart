import 'api_service.dart';
import '../models/vendor.dart';
import '../models/user.dart';

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
      final response = await _apiService.put('vendors.php', vendor.toJson());
      return response['success'] == true;
    } catch (e) {
      print('Error updating vendor profile: $e');
      return false;
    }
  }

  Future<Vendor?> getCurrentVendorProfile() async {
    // This would typically get the current user's ID from auth service
    // For now, we'll need to pass the vendor ID from the calling widget
    return null; // To be implemented with proper auth integration
  }
}
