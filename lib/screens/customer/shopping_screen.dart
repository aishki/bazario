import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/entypo.dart';

import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import 'c_cart_page.dart';

class ShoppingScreen extends StatefulWidget {
  final String category;
  final String customerId;

  const ShoppingScreen({
    super.key,
    required this.category,
    required this.customerId,
  });

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final ProductsService _productsService = ProductsService();
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool showLimitWarning = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _productsService.fetchProducts(category: widget.category);
    _productsFuture.then((products) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final nameMatch = product.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        final bpMatch = (product.businessPartnerId ?? '')
            .toLowerCase()
            .contains(query.toLowerCase());
        return nameMatch || bpMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle = widget.category == 'all'
        ? 'All Products'
        : widget.category[0].toUpperCase() + widget.category.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE970), // 🌼 background color
      body: SafeArea(
        child: Stack(
          children: [
            // --- Bottom container ---
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFADC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 8,
                      spreadRadius: 0,
                      inset: true, // 🟡 inner shadow (only top)
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // 🛒 Cart Button aligned top-right
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MyBasket(customerId: widget.customerId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD800),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE4C100),
                                width: 2,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "My Cart",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔍 Search Bar
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          border: Border.all(
                            color: const Color(0xFFDD602D),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterProducts,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                              color: Color(0xFFDD602D),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Search products or store',
                              hintStyle: TextStyle(
                                color: Color(0xFFDD602D),
                                fontFamily: 'Poppins',
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFFDD602D),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🏷️ Category Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          categoryTitle,
                          style: const TextStyle(
                            color: Color(0xFFDD602D),
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🛍️ Product Grid
                      Expanded(
                        child: FutureBuilder<List<Product>>(
                          future: _productsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.inkDrop(
                                  color: const Color(0xFFDD602D),
                                  size: 60,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            final products = _filteredProducts;
                            if (products.isEmpty) {
                              return const Center(
                                child: Text('No products available.'),
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.only(top: 10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _openProductDetailsDialog(
                                    context,
                                    products[index],
                                    widget.customerId,
                                  ),
                                  child: ProductCard(product: products[index]),
                                );
                              },
                            );
                          },
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
                        // Back button (top-left)
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
                        // Logo centered
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

  void _openProductDetailsDialog(
    BuildContext context,
    Product product,
    String customerId,
  ) {
    final CartService _cartService = CartService();
    int quantity = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFFFFD800).withOpacity(0.8),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              backgroundColor: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDD602D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟡 LEFT COLUMN – Product info
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFD400),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🖼️ Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl ?? '',
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // 🧾 Product Name
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Color(0xFFDD602D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // 🏪 Business Name
                                Row(
                                  children: [
                                    const Iconify(
                                      Entypo.shop,
                                      size: 14,
                                      color: Color(0xFFFF9E17),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "by ${product.businessPartnerName != null && product.businessPartnerName!.isNotEmpty ? product.businessPartnerName : 'Unknown'}",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Color(0xFFFF9E17),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // 💰 Price + Quantity in two rows
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // LEFT: Price + Business partner info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 💰 Price
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start, // makes inner items align top
                                              children: [
                                                Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFFDD602D,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Center(
                                                    child: Text(
                                                      '₱',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  product.price.toStringAsFixed(
                                                    0,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Color(0xFFDD602D),
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // RIGHT: Quantity controls
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Quantity",
                                          style: TextStyle(
                                            color: Color(0xFFFFB143),
                                            fontFamily: 'Poppins',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        // 🔢 Quantity Row
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (quantity > 1) {
                                                  setState(() {
                                                    quantity--;
                                                    showLimitWarning = false;
                                                  });
                                                }
                                              },
                                              child: Iconify(
                                                Ph.minus_circle,
                                                size: 17,
                                                color: quantity > 1
                                                    ? const Color(0xFFDD602D)
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                color: Color(0xFFDD602D),
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            GestureDetector(
                                              onTap: () {
                                                final maxLimit = product
                                                    .stock; // dynamically based on stock
                                                if (quantity < maxLimit) {
                                                  setState(() {
                                                    quantity++;
                                                    showLimitWarning = false;
                                                  });
                                                } else {
                                                  setState(
                                                    () =>
                                                        showLimitWarning = true,
                                                  );
                                                }
                                              },
                                              child: Iconify(
                                                Ph.plus_circle_fill,
                                                size: 17,
                                                color: quantity < product.stock
                                                    ? const Color(0xFFDD602D)
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // ⚠️ Reserve space for the warning
                                        SizedBox(
                                          height:
                                              16, // fixed height for warning slot
                                          child: AnimatedOpacity(
                                            opacity: showLimitWarning ? 1 : 0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: const Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                "Max limit",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 🟠 RIGHT COLUMN – Description + Button
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 32,
                              ), // adds space from top (close button)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 120,
                                  maxHeight: 180,
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    product.description.isNotEmpty
                                        ? product.description
                                        : "No description available.",
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Color(0xFFDD602D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _cartService.addToCart(
                                    customerId: customerId,
                                    productId: product.id,
                                    quantity: quantity,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Added to cart!"),
                                      backgroundColor: Color(0xFFDD602D),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9E17),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ❌ Close Button
                  Positioned(
                    top: -5,
                    right: -12,
                    child: SizedBox(
                      height: 30,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            icon: const Iconify(
                              IconParkSolid.delete_key,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

//
// 🧩 Reusable ProductCard Widget
//
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFD400), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl ?? '',
              height: 65,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(height: 8),

          // 🧾 Product name & price row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Product name + shop
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color(0xFFFFD800),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Iconify(
                            Entypo.shop,
                            size: 14,
                            color: Color(0xFFFF9E17),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "by ${product.businessPartnerName != null && product.businessPartnerName!.isNotEmpty ? product.businessPartnerName : 'Unknown'}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Color(0xFFFF9E17),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            product.stock > 0
                                ? "Stock: ${product.stock}"
                                : "Out of Stock",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins-Medium',
                              fontSize: 10,
                              color: Color(0xFFFF9E17),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price
          Row(
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  color: Color(0xFFDD602D),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '₱',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.price.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFFDD602D),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
