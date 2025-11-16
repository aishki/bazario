import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'cloudinary_service.dart';

class OrderPaymentsService {
  final String baseUrl =
      "https://bazario-backend-aszl.onrender.com/api/order_payments.php";

  final _cloudinary = CloudinaryService();

  /// Uploads payment info and image (if available)
  Future<Map<String, dynamic>> uploadPayment({
    required String orderId,
    required String referenceNumber,
    File? receiptImage,
  }) async {
    try {
      String? receiptUrl;

      // 1️⃣ Upload to Cloudinary if image is provided
      if (receiptImage != null) {
        final uploadResult = await _cloudinary.uploadImage(receiptImage);
        if (uploadResult != null) {
          receiptUrl = uploadResult.secureUrl;
        }
      }

      // 2️⃣ Send to backend
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "action": "add_payment",
          "order_id": orderId,
          "reference_number": referenceNumber,
          "receipt_url": receiptUrl,
        }),
      );

      final decoded = json.decode(response.body);
      print("💰 Payment upload response: $decoded");
      return decoded;
    } catch (e) {
      print("💥 Error uploading payment: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// Optional: fetch payments linked to an order
  Future<Map<String, dynamic>> getPayments(String orderId) async {
    final response = await http.get(Uri.parse("$baseUrl?order_id=$orderId"));
    return json.decode(response.body);
  }
}
