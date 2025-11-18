import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/entypo.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../services/cart_service.dart';
import '../../services/orders_service.dart';
import 'c_order_status_screen.dart';
import 'check_out_screen.dart';

class MyBasket extends StatefulWidget {
  final String customerId;

  const MyBasket({super.key, required this.customerId});

  @override
  State<MyBasket> createState() => _MyBasketState();
}

class _MyBasketState extends State<MyBasket> {
  final CartService _cartService = CartService();
  final OrdersService _ordersService = OrdersService();

  Map<String, dynamic>? _cartData;
  bool _loading = true;
  Map<String, bool> shopSelected = {}; // select all per shop
  Map<String, bool> itemSelected = {}; // individual item checkboxes

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _loading = true);
    final data = await _cartService.getCart(widget.customerId);
    setState(() {
      _cartData = data;
      _loading = false;
      _initializeSelections();
    });
  }

  void _initializeSelections() {
    final items = _cartData?['cart']?['items'] ?? [];
    for (var item in items) {
      itemSelected[item['cart_item_id'].toString()] = false;
    }
  }

  double get total {
    if (_cartData == null || _cartData!['cart'] == null) return 0;
    final items = _cartData!['cart']['items'] as List<dynamic>;
    return items.fold(0, (sum, item) {
      final id = item['cart_item_id'];
      if (itemSelected[id] == true) {
        final price = double.tryParse(item['price'].toString()) ?? 0;
        return sum + (price * item['quantity']);
      }
      return sum;
    });
  }

  Future<void> _checkout() async {
    final selectedItems = _cartData!['cart']['items']
        .where((item) => itemSelected[item['cart_item_id'].toString()] == true)
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one item")),
      );
      return;
    }

    final selectedIds = selectedItems.map((e) => e['cart_item_id']).toList();

    setState(() => _loading = true); // 🧡 Start loader before checkout

    try {
      final res = await _ordersService.placeOrder(
        widget.customerId,
        selectedIds,
        totalAmount: total,
      );

      if (res["success"]) {
        final clearRes = await _cartService.clearCart(
          widget.customerId,
          cartItemIds: selectedIds.map((e) => e.toString()).toList(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Order placed successfully"),
          ),
        );

        if (clearRes["success"] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res["message"] ?? "Checkout failed")),
          );
        }
      }

      // 🔁 Refresh cart after success or fail
      await _fetchCart();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error during checkout: $e")));
    } finally {
      setState(() => _loading = false); // 💚 Stop loader after done
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartData?['cart']?['items'] ?? [];

    // Group by shop
    final shops = <String, List<dynamic>>{};
    for (var item in cartItems) {
      final shop = item['business_name'] ?? 'Unknown';
      shops.putIfAbsent(shop, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFE970),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // --- Header Row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                SolarIconsBold.shop,
                                color: Color(0xFFFF9E17),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "My Basket",
                                style: TextStyle(
                                  fontFamily: "Bagel Fat One",
                                  color: Color(0xFFFF9E17),
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4A00),
                              side: const BorderSide(
                                color: Color(0xFFFF9E17),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // Placeholder for My Orders
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderStatusScreen(
                                    customerId: widget.customerId,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "My Orders",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- Cart Items Grouped by Shop ---
                      Expanded(
                        child: _loading
                            ? Center(
                                child: LoadingAnimationWidget.inkDrop(
                                  color: const Color(0xFFDD602D),
                                  size: 60,
                                ),
                              )
                            : cartItems.isEmpty
                            ? const Center(child: Text("No items in cart"))
                            : ListView(
                                children: [
                                  for (var entry in shops.entries) ...[
                                    // Shop Header Row
                                    Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        Checkbox(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          activeColor: const Color(0xFF74CC00),
                                          value:
                                              shopSelected[entry.key] ?? false,
                                          onChanged: (val) {
                                            setState(() {
                                              shopSelected[entry.key] =
                                                  val ?? false;
                                              for (var item in entry.value) {
                                                itemSelected[item['cart_item_id']
                                                        .toString()] =
                                                    val ?? false;
                                              }
                                            });
                                          },
                                        ),
                                        const Iconify(
                                          Entypo.shop,
                                          size: 14,
                                          color: Color(0xFF74CC00),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF74CC00),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Product Items under the Shop
                                    for (var item in entry.value) ...[
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // ✅ Checkbox
                                            Checkbox(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              activeColor: const Color(
                                                0xFF74CC00,
                                              ),
                                              value:
                                                  itemSelected[item['cart_item_id']
                                                      .toString()] ??
                                                  false,
                                              onChanged: (val) {
                                                setState(() {
                                                  itemSelected[item['cart_item_id']
                                                          .toString()] =
                                                      val!;
                                                });
                                              },
                                            ),

                                            // ✅ Product Image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                item['image_url'],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            // ✅ Product Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFFDD602D),
                                                    ),
                                                  ),
                                                  Text(
                                                    "₱${item['price']} x ${item['quantity']}",
                                                    style: const TextStyle(
                                                      color: Color(0xFFFF9E17),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // 🔢 Quantity Controls
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Quantity:",
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFFFB143,
                                                          ),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),

                                                      // ➖ Minus
                                                      GestureDetector(
                                                        onTap: () async {
                                                          if (item['quantity'] >
                                                              1) {
                                                            await _cartService
                                                                .updateQuantity(
                                                                  cartItemId:
                                                                      item['cart_item_id'],
                                                                  quantity:
                                                                      item['quantity'] -
                                                                      1,
                                                                );
                                                            _fetchCart();
                                                          }
                                                        },
                                                        child: Iconify(
                                                          Entypo.minus,
                                                          size: 16,
                                                          color:
                                                              item['quantity'] >
                                                                  1
                                                              ? const Color(
                                                                  0xFFDD602D,
                                                                )
                                                              : Colors
                                                                    .grey
                                                                    .shade400,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 8),

                                                      // 🔢 Quantity Text
                                                      Text(
                                                        '${item['quantity']}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFFDD602D,
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 8),

                                                      // ➕ Plus
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final stock =
                                                              int.tryParse(
                                                                item['stock']
                                                                    .toString(),
                                                              ) ??
                                                              0;
                                                          if (item['quantity'] <
                                                              stock) {
                                                            await _cartService
                                                                .updateQuantity(
                                                                  cartItemId:
                                                                      item['cart_item_id'],
                                                                  quantity:
                                                                      item['quantity'] +
                                                                      1,
                                                                );
                                                            _fetchCart();
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  "Reached max stock limit",
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                      seconds:
                                                                          1,
                                                                    ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Iconify(
                                                          Entypo.plus,
                                                          size: 16,
                                                          color:
                                                              (item['quantity'] <
                                                                  (int.tryParse(
                                                                        item['stock']
                                                                            .toString(),
                                                                      ) ??
                                                                      0))
                                                              ? const Color(
                                                                  0xFFDD602D,
                                                                )
                                                              : Colors
                                                                    .grey
                                                                    .shade400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // 🗑️ Delete Button (right-most)
                                            IconButton(
                                              icon: const Iconify(
                                                Entypo.trash,
                                                color: Color(0xFFDD602D),
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showDeleteDialog(
                                                    context,
                                                    item,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 5),
                                  ],
                                ],
                              ),
                      ),

                      // --- Total + Checkout ---
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: ₱${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: total == 0
                                  ? null
                                  : () {
                                      final selectedItems =
                                          _cartData!['cart']['items']
                                              .where(
                                                (item) =>
                                                    itemSelected[item['cart_item_id']
                                                        .toString()] ==
                                                    true,
                                              )
                                              .toList();

                                      if (selectedItems.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select at least one item",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CheckOutScreen(
                                            customerId: widget.customerId,
                                            selectedItems:
                                                selectedItems, // ✅ pass data
                                          ),
                                        ),
                                      );
                                    },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7482B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Checkout",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Top logo + back button ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                        Image.asset(
                          'lib/assets/images/bazario-logo.png',
                          width: 120,
                        ),
                      ],
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

  void _showDeleteDialog(BuildContext pageContext, Map<String, dynamic> item) {
    showDialog(
      barrierDismissible: false,
      barrierColor: const Color(0xFF792401).withOpacity(0.3),
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Remove Item",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD602D),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),

                // Message
                Text(
                  "Are you sure you want to remove \"${item['name']}\" from your cart?",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Color(0xFF792401),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        foregroundColor: const Color(0xFFDD602D),
                        side: const BorderSide(color: Color(0xFFDD602D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        backgroundColor: const Color(0xFFDD602D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);

                        await _cartService.updateQuantity(
                          cartItemId: item['cart_item_id'],
                          quantity: 0,
                        );

                        if (!mounted) return;

                        _fetchCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "\"${item['name']}\" removed from cart.",
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        "Remove",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
