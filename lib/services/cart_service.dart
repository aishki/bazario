import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl =
      "https://bazario-backend-aszl.onrender.com/api/cart.php";

  // 🛒 Fetch the user's cart
  Future<Map<String, dynamic>> getCart(String customerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl?customer_id=$customerId"),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print('🛒 Cart response: $decoded'); // 👈 Add this line
      return decoded;
    } else {
      throw Exception("Failed to load cart");
    }
  }

  // ➕ Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required String customerId,
    required String productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "customer_id": customerId,
        "product_id": productId,
        "quantity": quantity,
      }),
    );
    return json.decode(response.body);
  }

  // 📝 Update item quantity
  Future<Map<String, dynamic>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"cart_item_id": cartItemId, "quantity": quantity}),
    );
    return json.decode(response.body);
  }

  // 🗑️ Clear cart
  Future<Map<String, dynamic>> clearCart(
    String customerId, {
    List<dynamic>? cartItemIds,
  }) async {
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "customer_id": customerId,
        if (cartItemIds != null && cartItemIds.isNotEmpty)
          "cart_item_ids": cartItemIds,
      }),
    );

    return json.decode(response.body);
  }
}
