import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/orders_service.dart';
import '../../services/cart_service.dart';
import '../../services/customer_service.dart';
import '../../services/order_payments_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/customer.dart';
import 'c_order_status_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:solar_icons/solar_icons.dart';

class PayNowScreen extends StatefulWidget {
  final String customerId;
  final List<dynamic> selectedItems;
  final double totalAmount;
  final double deliveryFee;

  const PayNowScreen({
    super.key,
    required this.customerId,
    required this.selectedItems,
    required this.totalAmount,
    required this.deliveryFee,
  });

  @override
  State<PayNowScreen> createState() => _PayNowScreenState();
}

class _PayNowScreenState extends State<PayNowScreen> {
  final _refController = TextEditingController();
  File? _receiptImage;
  bool _loading = false;

  final _ordersService = OrdersService();
  final _cartService = CartService();
  final _customerService = CustomerService();

  Customer? _customer;
  Future<void> _loadCustomer() async {
    final customer = await _customerService.getCustomerProfile(
      widget.customerId,
    );
    if (customer != null) {
      setState(() => _customer = customer);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _receiptImage = File(picked.path));
    }
  }

  Future<void> _confirmPayment() async {
    if (_refController.text.isEmpty || _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final selectedIds = widget.selectedItems
          .map((e) => e['cart_item_id'])
          .toList();

      // 1️⃣ Place the order first
      final orderRes = await _ordersService.placeOrder(
        widget.customerId,
        selectedIds,
        totalAmount: widget.totalAmount,
        deliveryFee: widget.deliveryFee,
        status: 'paid',
      );

      if (orderRes['success'] != true || orderRes['order_id'] == null) {
        throw Exception(orderRes['message'] ?? "Failed to place order");
      }

      final String orderId = orderRes['order_id'];

      // 2️⃣ Upload payment info (with image)
      final paymentRes = await OrderPaymentsService().uploadPayment(
        orderId: orderId,
        referenceNumber: _refController.text.trim(),
        receiptImage: _receiptImage,
      );

      if (paymentRes['success'] != true) {
        print("⚠️ Payment record failed: ${paymentRes['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment upload failed: ${paymentRes['message']}"),
            backgroundColor: Colors.red,
          ),
        );
        return; // stop flow if payment upload fails
      }

      print("✅ Payment successfully recorded in order_payments table");

      // 3️⃣ Clear the cart
      await _cartService.clearCart(widget.customerId, cartItemIds: selectedIds);

      // 4️⃣ Notify user and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment confirmed! Order placed successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderStatusScreen(
            customerId: widget.customerId,
            fromPayment: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE970),
      resizeToAvoidBottomInset:
          true, // ✅ allows layout to adjust when keyboard shows
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              bottom: 0,
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
                  child: SingleChildScrollView(
                    // ✅ Make it scrollable
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Row(
                          children: const [
                            Icon(
                              Icons.receipt_long,
                              color: Color(0xFFFF9E17),
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "PAYMENT",
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
                        if (_customer != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "${_customer!.address}, ${_customer!.city}, ${_customer!.postalCode}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // --- GCash QR ---
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "Scan to Pay via GCash",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Image.network(
                                'https://res.cloudinary.com/ddnkxzfii/image/upload/v1760352748/gcash-qr_odbsvm.jpg',
                                width: 200,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // --- Total Amount ---
                        Text(
                          "Total Amount: ₱${widget.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // --- Reference Number ---
                        TextField(
                          controller: _refController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD7FBA9),
                            labelText: "Reference Number",
                            labelStyle: const TextStyle(
                              fontFamily: "Poppins",
                              color: Color(0xFF569109),
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF74CC00)),
                        ),
                        const SizedBox(height: 16),

                        // --- Upload Receipt Button ---
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFFFB4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  SolarIconsBold.upload,
                                  size: 28,
                                  color: Color(0xFF74CC00),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _receiptImage == null
                                      ? "Upload Receipt"
                                      : "Change Image",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF74CC00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_receiptImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Image.file(_receiptImage!, height: 120),
                          ),

                        const SizedBox(height: 24),

                        // --- Confirm Payment Button ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _confirmPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF7482B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? Center(
                                    child:
                                        LoadingAnimationWidget.horizontalRotatingDots(
                                          color: Color(0xFFDD602D),
                                          size: 35,
                                        ),
                                  )
                                : const Text(
                                    "CONFIRM PAYMENT",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
