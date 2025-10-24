import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../screens/customer/c_cart_page.dart';
import 'package:intl/intl.dart';

class OrderRowWidget extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderRowWidget({super.key, required this.order, required this.onTap});

  @override
  State<OrderRowWidget> createState() => _OrderRowWidgetState();
}

class _OrderRowWidgetState extends State<OrderRowWidget> {
  bool showAllShops = false;
  final CartService _cartService = CartService();

  Future<void> _handleBuyAgain(BuildContext context) async {
    final order = widget.order;
    final shops = order['shops'] as List<dynamic>? ?? [];

    try {
      for (final shop in shops) {
        final items = shop['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          await _cartService.addToCart(
            customerId: order['customer_id'],
            productId: item['product_id'],
            quantity: item['quantity'],
          );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🛒 Order items added to cart!'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Redirect to Cart Page after adding items
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyBasket(customerId: order['customer_id']),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final shops = order['shops'] as List<dynamic>? ?? [];

    // --- Determine UI mode based on order status ---
    final status = (order['status'] as String).toLowerCase();
    final bool isStatusTab =
        status == 'pending' || status == 'paid' || status == 'payment verified';
    final bool isToReceive = status == 'to receive';
    final bool isCompleted = status == 'completed';
    final bool isCancelled = status == 'cancelled' || status == 'refunded';

    // --- Status configuration (for Status tab only) ---
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (status == 'paid') {
      statusColor = const Color(0xFFFF9E17);
      statusLabel = 'Payment Under Review';
      statusIcon = Icons.error_outline;
    } else if (status == 'payment verified') {
      statusColor = const Color(0xFF74CC00);
      statusLabel = 'Order is being prepared';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = const Color(0xFFFF9E17);
      statusLabel = 'Pending';
      statusIcon = Icons.hourglass_bottom;
    }

    // Flatten all items across shops for total count
    final allItems = shops
        .expand((shop) => shop['items'] as List<dynamic>)
        .toList();
    final totalQuantity = allItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    // Show only one shop by default
    final visibleShops = showAllShops ? shops : shops.take(1).toList();

    // --- Dynamic styling ---
    Color iconColor;
    Color businessNameColor;
    Color bgColor;
    Border? border;

    if (isStatusTab) {
      bgColor = const Color(0xFFF3E283);
      iconColor = const Color(0xFF242424).withOpacity(0.63);
      businessNameColor = const Color(0xFF242424).withOpacity(0.63);
      border = const Border(
        top: BorderSide(color: Colors.white, width: 1),
        bottom: BorderSide(color: Colors.white, width: 1),
      );
    } else if (isToReceive) {
      bgColor = Colors.white;
      iconColor = const Color(0xFFFF9E17);
      businessNameColor = const Color(0xFFFF9E17);
      border = Border.all(color: const Color(0xFFFF5C19), width: 2);
    } else if (isCompleted) {
      bgColor = Colors.white;
      iconColor = const Color(0xFF569109);
      businessNameColor = const Color(0xFF569109);
      border = null;
    } else if (isCancelled) {
      bgColor = Colors.white;
      iconColor = const Color(0xFFFF9E17);
      businessNameColor = const Color(0xFFFF9E17);
      border = Border.all(color: const Color(0xFFFF5C19), width: 2);
    } else {
      bgColor = const Color(0xFFF3E283);
      iconColor = const Color(0xFFDD602D).withOpacity(0.63);
      businessNameColor = const Color(0xFFDD602D).withOpacity(0.63);
      border = const Border(
        top: BorderSide(color: Colors.white, width: 1),
        bottom: BorderSide(color: Colors.white, width: 1),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: border is Border
              ? border
              : (border is BorderDirectional ? border : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Order Info ---
            Row(
              children: [
                Icon(Icons.receipt_long, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  "Order ID: ${order['id'].toString().substring(0, 8)}...",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: businessNameColor,
                  ),
                ),
                const Spacer(),
                if (isStatusTab) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: statusColor, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isToReceive) ...[
                  Row(
                    children: const [
                      Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: Color(0xFFDD602D),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "The courier is on the way!",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD602D),
                        ),
                      ),
                    ],
                  ),
                ] else if (isCompleted) ...[
                  Row(
                    children: const [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF569109),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Completed",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF569109),
                        ),
                      ),
                    ],
                  ),
                ] else if (isCancelled) ...[
                  Row(
                    children: const [
                      Icon(Icons.cancel, size: 16, color: Color(0xFFFF390F)),
                      SizedBox(width: 4),
                      Text(
                        "Cancelled",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF390F),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 6),

            // --- Shops and Their Items ---
            ...visibleShops.map((shop) {
              final items = shop['items'] as List<dynamic>? ?? [];
              final visibleItems = items.take(1).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: iconColor.withOpacity(0.2), thickness: 1),
                  Row(
                    children: [
                      Icon(Icons.storefront, size: 14, color: iconColor),
                      const SizedBox(width: 4),
                      Text(
                        shop['business_name'] ?? 'Unknown Shop',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: businessNameColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...visibleItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: iconColor, width: 2),
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: NetworkImage(item['image_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['name'],
                              style: TextStyle(
                                color: businessNameColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "x${item['quantity']}",
                                style: TextStyle(
                                  color: businessNameColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₱${item['price']}",
                                style: TextStyle(
                                  color: businessNameColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            // --- View More toggle ---
            if (shops.length > 1 ||
                shops.any((s) => (s['items'] as List).length > 1))
              GestureDetector(
                onTap: () => setState(() => showAllShops = !showAllShops),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAllShops ? "View Less ▲" : "View More ▼",
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Divider(color: iconColor.withOpacity(0.2), thickness: 1),

            // --- Total Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total $totalQuantity item(s):",
                  style: TextStyle(
                    color: businessNameColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: businessNameColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '₱',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${order['total_amount']}",
                      style: TextStyle(
                        color: businessNameColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // --- Extra UI based on status ---
            if (isToReceive) ...[
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFFFD800), thickness: 2),
              Text(
                "RIDER INFORMATION:",
                style: TextStyle(
                  color: businessNameColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text(
                    "Name: ",
                    style: TextStyle(
                      color: Color(0xFFFF9E17),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Nonoy Esther Liu",
                    style: TextStyle(color: Color(0xFFDD602D), fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    "Contact Number: ",
                    style: TextStyle(
                      color: Color(0xFFFF9E17),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "09123678633",
                    style: TextStyle(color: Color(0xFFDD602D), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Estimated Arrival: ",
                    style: TextStyle(
                      color: const Color(0xFFFF9E17),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(
                      (DateTime.parse(
                        order['created_at'],
                      ).add(const Duration(hours: 1))),
                    ),
                    style: const TextStyle(
                      color: Color(0xFFDD602D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            if (isCompleted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9E17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _handleBuyAgain(context),
                  child: const Text(
                    "Buy Again",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],

            if (isCancelled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Refund details coming soon"),
                          ),
                        );
                      },
                      child: const Text(
                        "Refund Details",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9E17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _handleBuyAgain(context),
                      child: const Text(
                        "Buy Again",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
