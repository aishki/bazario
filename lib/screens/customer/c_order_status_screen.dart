import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../components/order_row_widget.dart';
import '../../services/orders_service.dart';
import 'package:bazario/services/auth_service.dart';
import 'package:bazario/components/customer_navbar.dart';
import 'package:bazario/models/customer.dart';

class OrderStatusScreen extends StatefulWidget {
  final String customerId;
  final bool fromPayment;
  const OrderStatusScreen({
    super.key,
    required this.customerId,
    this.fromPayment = false,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final OrdersService _ordersService = OrdersService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  String selectedTab = 'Status';

  final Map<String, Color> tabColors = {
    'Status': const Color(0xFFFFD800),
    'To Receive': const Color(0xFFFF9E17),
    'Completed': const Color(0xFF74CC00),
    'Canceled': const Color(0xFFFF8553),
  };

  @override
  void initState() {
    super.initState();
    _ordersFuture = _ordersService.fetchOrders(widget.customerId);
  }

  // 🟡 Filter orders by tab selection
  List<Map<String, dynamic>> _filterOrdersByTab(
    List<Map<String, dynamic>> allOrders,
  ) {
    switch (selectedTab) {
      case 'Status':
        return allOrders
            .where(
              (order) =>
                  order['status'] == 'pending' ||
                  order['status'] == 'paid' ||
                  order['status'] == 'payment verified',
            )
            .toList();

      case 'To Receive':
        return allOrders
            .where((order) => order['status'] == 'to receive')
            .toList();

      case 'Completed':
        return allOrders
            .where((order) => order['status'] == 'completed')
            .toList();

      case 'Canceled':
        return allOrders
            .where(
              (order) =>
                  order['status'] == 'cancelled' ||
                  order['status'] == 'refunded',
            )
            .toList();

      default:
        return allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE970),
      body: SafeArea(
        child: Stack(
          children: [
            // --- Main Container ---
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Row ---
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            SolarIconsBold.cart,
                            color: Color(0xFFFF9E17),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "MY ORDERS",
                            style: TextStyle(
                              fontFamily: "Bagel Fat One",
                              color: Color(0xFFFF9E17),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Tabs ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabColors.entries.map((entry) {
                          final isActive = selectedTab == entry.key;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedTab = entry.key);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: entry.value,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: entry.value.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // --- Order List ---
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: tabColors[selectedTab],
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _ordersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error loading orders: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            final allOrders = snapshot.data ?? [];
                            final filteredOrders = _filterOrdersByTab(
                              allOrders,
                            );

                            if (filteredOrders.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No orders found.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return OrderRowWidget(
                                  order: order,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/orderDetails',
                                      arguments: order,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Top Bar ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
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
                        onPressed: () async {
                          if (widget.fromPayment) {
                            final session = await AuthService()
                                .getUserSession();
                            if (session != null) {
                              final userId = session['id'];
                              final username = session['business_name'];

                              final customer = Customer(
                                id: userId,
                                username: username,
                                email: '', // or from API
                                createdAt: DateTime.now(), // or stored date
                              );

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerNavBar(
                                    userId: userId,
                                    username: username,
                                    customerId: userId,
                                    customer: customer,
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
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
            ),
          ],
        ),
      ),
    );
  }
}
