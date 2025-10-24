import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/entypo.dart';
import 'pay_now_screen.dart';
import '../../services/customer_service.dart';
import '../../models/customer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../components/map_widget.dart';
import 'dart:math' show cos, sqrt, asin;

class CheckOutScreen extends StatefulWidget {
  final String customerId;
  final List<dynamic> selectedItems;

  const CheckOutScreen({
    super.key,
    required this.customerId,
    required this.selectedItems,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final CustomerService _customerService = CustomerService();
  Customer? _customer;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _editAddressController = TextEditingController();
  final TextEditingController _editCityController = TextEditingController();
  final TextEditingController _editPostalController = TextEditingController();

  // 📍 Base location: USLS Courtyard
  final double baseLat = 10.68061132169949;
  final double baseLon = 122.96186362984275;

  double? deliveryDistance;
  double? deliveryFee;

  Future<Map<String, double>?> getLatLngFromAddress(String address) async {
    try {
      final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1",
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'BazarioApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
          };
        }
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
    }
    return null;
  }

  // 🧭 Compute Haversine distance
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // π/180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // Distance in km
  }

  // 🚚 Compute delivery fee based on distance
  double computeDeliveryFee(double distanceKm) {
    const baseFee = 49;
    if (distanceKm <= 5) {
      return (baseFee + distanceKm * 6).roundToDouble();
    } else {
      return (baseFee + (5 * 6) + ((distanceKm - 5) * 5)).roundToDouble();
    }
  }

  void _showEditAddressDialog() {
    if (_customer == null) return;

    _editAddressController.text = _customer!.address ?? '';
    _editCityController.text = _customer!.city ?? '';
    _editPostalController.text = _customer!.postalCode ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFD400), width: 2),
          ),
          backgroundColor: const Color(0xFFFFF7E6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Address 🏡",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF792401),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Update your delivery address details below.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Color(0xFF5A2401),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address Input
                  TextField(
                    controller: _editAddressController,
                    decoration: InputDecoration(
                      labelText: "Address",
                      labelStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Color(0xFF5A2401),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFFD400)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF792401),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // City Input
                  TextField(
                    controller: _editCityController,
                    decoration: InputDecoration(
                      labelText: "City",
                      labelStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Color(0xFF5A2401),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFFD400)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF792401),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Postal Code Input
                  TextField(
                    controller: _editPostalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Postal Code",
                      labelStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Color(0xFF5A2401),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFFD400)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF792401),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFFFFD400),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Color(0xFF792401),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Save Button
                      TextButton(
                        onPressed: () async {
                          if (!_editCityController.text
                              .toLowerCase()
                              .startsWith("bacolod")) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "The delivery service only caters within Bacolod City.",
                                ),
                              ),
                            );
                            return;
                          }

                          final fullAddress =
                              "${_editAddressController.text}, ${_editCityController.text}, ${_editPostalController.text}";
                          final coords = await getLatLngFromAddress(
                            fullAddress,
                          );

                          if (coords == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Failed to find location for this address",
                                ),
                              ),
                            );
                            return;
                          }

                          _customer = Customer(
                            id: _customer!.id,
                            email: _customer!.email,
                            profileUrl: _customer!.profileUrl,
                            firstName: _customer!.firstName,
                            middleName: _customer!.middleName,
                            lastName: _customer!.lastName,
                            suffix: _customer!.suffix,
                            username: _customer!.username,
                            phoneNumber: _customer!.phoneNumber,
                            address: _editAddressController.text,
                            city: _editCityController.text,
                            postalCode: _editPostalController.text,
                            latitude: coords['lat'],
                            longitude: coords['lon'],
                            createdAt: _customer!.createdAt,
                          );

                          final success = await _customerService
                              .updateCustomerProfile(_customer!);

                          if (success) {
                            _updateDeliveryInfo(_customer);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Address updated successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to update address"),
                              ),
                            );
                          }

                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Color(0xFF792401),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double get subtotal {
    double total = 0;
    for (var item in widget.selectedItems) {
      final price = double.tryParse(item['price'].toString()) ?? 0;
      final qty = int.tryParse(item['quantity'].toString()) ?? 0;
      total += price * qty;
    }
    return total;
  }

  void _updateDeliveryInfo([Customer? customCustomer]) {
    final customer = customCustomer ?? _customer;
    if (customer?.latitude != null && customer?.longitude != null) {
      final dist = calculateDistance(
        baseLat,
        baseLon,
        customer!.latitude!,
        customer.longitude!,
      );
      final fee = computeDeliveryFee(dist);
      setState(() {
        deliveryDistance = dist;
        deliveryFee = fee;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  Future<void> _fetchCustomerProfile() async {
    final profile = await _customerService.getCustomerProfile(
      widget.customerId,
    );

    if (profile != null) {
      setState(() {
        _customer = profile;
        _addressController.text = _customer!.address ?? '';
      });

      // ✅ Make sure delivery info is computed AFTER setting state
      if (profile.latitude != null && profile.longitude != null) {
        final dist = calculateDistance(
          baseLat,
          baseLon,
          profile.latitude!,
          profile.longitude!,
        );
        final fee = computeDeliveryFee(dist);
        setState(() {
          deliveryDistance = dist;
          deliveryFee = fee;
        });
      } else {
        // Optional: fallback notice
        print("⚠️ No coordinates found for user; cannot compute delivery fee.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fee = deliveryFee ?? 0;
    final totalAmount = subtotal + fee;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE970),
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Image.asset('lib/assets/images/bazario-logo.png', width: 120),
                ],
              ),
            ),

            // --- Scrollable Content ---
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFADC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.receipt_long,
                            color: Color(0xFFFF9E17),
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "CHECKOUT",
                            style: TextStyle(
                              fontFamily: "Bagel Fat One",
                              color: Color(0xFFFF9E17),
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Address Box ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Color(0xFFDD602D),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Address",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDD602D),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${_customer?.address ?? ''}, ${_customer?.city ?? ''}, ${_customer?.postalCode ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showEditAddressDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7482B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Update",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_customer?.latitude != null &&
                          _customer?.longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildMapView(
                            Position(
                              latitude: _customer!.latitude!,
                              longitude: _customer!.longitude!,
                              timestamp: DateTime.now(),
                              accuracy: 0,
                              altitude: 0,
                              heading: 0,
                              speed: 0,
                              speedAccuracy: 0,
                              altitudeAccuracy: 0.0,
                              headingAccuracy: 0.0,
                            ),
                          ),
                        ),

                      // --- Item List ---
                      ..._buildGroupedItems(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom Total + Pay Now ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFFFFFADC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total No. of Items: ${widget.selectedItems.length}"),
                  Text("Subtotal: ₱${subtotal.toStringAsFixed(2)}"),
                  Text(
                    "Delivery Distance: ${(deliveryDistance ?? 0).toStringAsFixed(2)} km",
                  ),
                  Text("Delivery Fee: ₱${fee.toStringAsFixed(0)}"),
                  const Divider(),
                  Text(
                    "Total Amount: ₱${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDD602D),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7482B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PayNowScreen(
                            customerId: widget.customerId,
                            selectedItems: widget.selectedItems,
                            totalAmount: totalAmount,
                            deliveryFee: deliveryFee ?? 0.0,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper to group items by shop
  List<Widget> _buildGroupedItems() {
    final Map<String, List<dynamic>> groupedByShop = {};
    for (var item in widget.selectedItems) {
      final shopName = item['business_name'] ?? 'Unknown Shop';
      groupedByShop.putIfAbsent(shopName, () => []).add(item);
    }

    return groupedByShop.entries.map((entry) {
      final shopName = entry.key;
      final shopItems = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Iconify(Entypo.shop, size: 16, color: Color(0xFF74CC00)),
              const SizedBox(width: 6),
              Text(
                shopName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF74CC00),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...shopItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item['image_url'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD602D),
                          ),
                        ),
                        Text(
                          "₱${item['price']} × ${item['quantity']}",
                          style: const TextStyle(
                            color: Color(0xFFFF9E17),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
