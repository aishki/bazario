import 'dart:convert';
import 'package:http/http.dart' as http;

class OrdersService {
  final String baseUrl =
      "https://bazario-backend-aszl.onrender.com/api/orders.php";

  // 🟢 Place an order (checkout)
  Future<Map<String, dynamic>> placeOrder(
    String customerId,
    List<dynamic> cartItemIds, {
    required double totalAmount,
    double deliveryFee = 0,
    String status = 'pending',
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "customer_id": customerId,
        "cart_item_ids": cartItemIds,
        "total_amount": totalAmount,
        "delivery_fee": deliveryFee,
        "status": status,
      }),
    );

    return json.decode(response.body);
  }

  // 🟣 Fetch all orders for a customer
  Future<List<Map<String, dynamic>>> fetchOrders(String customerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl?customer_id=$customerId"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true && data['orders'] != null) {
        // Return each order as-is (with its list of shops)
        return List<Map<String, dynamic>>.from(data['orders']);
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Failed to fetch orders. Status code: ${response.statusCode}',
      );
    }
  }

  // 🟡 Update order status (optional)
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"order_id": orderId, "status": status}),
    );

    return json.decode(response.body);
  }

  // 🔴 Delete order (optional)
  Future<Map<String, dynamic>> deleteOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"order_id": orderId}),
    );

    return json.decode(response.body);
  }
}
