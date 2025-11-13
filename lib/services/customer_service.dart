import 'api_service.dart';
import '../models/customer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CustomerService {
  final ApiService _apiService = ApiService();
  Future<Map<String, String>> getAddressFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          "address": "${place.street ?? ''} ${place.subLocality ?? ''}".trim(),
          "city": place.locality ?? '',
          "postal_code": place.postalCode ?? '',
        };
      }
    } catch (e) {
      print('[v0] Error reverse geocoding: $e');
    }
    return {"address": "", "city": "", "postal_code": ""};
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services disabled");

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception("Location permissions denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Fetch all customers
  Future<List<Customer>> getCustomers() async {
    final response = await _apiService.get('customers.php');
    if (response['success'] == true && response['customers'] != null) {
      return (response['customers'] as List)
          .map((c) => Customer.fromJson(c))
          .toList();
    }
    return [];
  }

  /// Fetch a specific customer's profile by ID
  Future<Customer?> getCustomerProfile(String customerId) async {
    final response = await _apiService.get(
      'customers.php?customer_id=$customerId',
    );
    if (response['success'] == true && response['customer'] != null) {
      return Customer.fromJson(response['customer']);
    }
    return null;
  }

  /// Update customer profile
  Future<bool> updateCustomerProfile(Customer customer) async {
    try {
      print('[v0] Updating customer profile for: ${customer.id}');
      print('[v0] Customer data: ${customer.toJson()}');
      final response = await _apiService.put(
        'customers.php',
        customer.toJson(),
      );
      print('[v0] API response: $response');
      return response['success'] == true;
    } catch (e) {
      print('[v0] Error updating customer profile: $e');
      return false;
    }
  }

  /// Fetch current logged-in customer's profile (optional integration with auth)
  Future<Customer?> getCurrentCustomerProfile() async {
    // Placeholder for when you integrate authentication token storage
    return null;
  }

  /// Delete a customer account (if applicable)
  Future<bool> deleteCustomer(String customerId) async {
    try {
      final response = await _apiService.delete('customers.php', {
        'id': customerId,
      });
      return response['success'] == true;
    } catch (e) {
      print('[v0] Error deleting customer: $e');
      return false;
    }
  }

  /// Add a new customer (for admin or testing use)
  Future<Map<String, dynamic>> addCustomer({
    required String firstName,
    required String lastName,
    required String email,
    String? username,
    String? password,
  }) async {
    try {
      print('[v0] Adding new customer: $firstName $lastName');
      final response = await _apiService.post('customers.php', {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'username': username,
        'password': password,
      });
      print('[v0] API response: $response');
      return response;
    } catch (e) {
      print('[v0] Error adding customer: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // /// Example: Fetch customer orders (if applicable)
  // Future<List<CustomerOrder>> getCustomerOrders(String customerId) async {
  //   final response = await _apiService.get(
  //     'customer_orders.php?customer_id=$customerId',
  //   );
  //   if (response['success'] == true && response['orders'] != null) {
  //     return (response['orders'] as List)
  //         .map((orderJson) => CustomerOrder.fromJson(orderJson))
  //         .toList();
  //   }
  //   return [];
  // }
}
