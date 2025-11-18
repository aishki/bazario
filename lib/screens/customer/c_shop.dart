import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

import 'package:solar_icons/solar_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/maki.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import '../login_screen.dart';
import 'c_cart_page.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import 'shopping_screen.dart';

class CustomerShop extends StatefulWidget {
  final bool isBrowseMode;
  final dynamic customer;
  final String customerId;

  const CustomerShop({
    super.key,
    this.isBrowseMode = false,
    this.customer,
    required this.customerId,
  });

  @override
  State<CustomerShop> createState() => _CustomerShopState();
}

class _CustomerShopState extends State<CustomerShop> {
  final List<String> _eventBanners = [
    'lib/assets/images/whats-hot-events/banner-1.png',
    'lib/assets/images/whats-hot-events/banner-2.png',
    'lib/assets/images/whats-hot-events/banner-3.png',
    'lib/assets/images/whats-hot-events/banner-4.png',
    'lib/assets/images/whats-hot-events/banner-5.png',
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isBrowseMode = widget.isBrowseMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          boxShadow: null,
          image: DecorationImage(
            image: AssetImage('lib/assets/images/customer-shop-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // --- Top Yellow Container ---
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE970),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  border: Border.all(color: const Color(0xFFFF9E17), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    const SizedBox(
                      height: 40,
                    ), // ✅ Slightly more breathing room
                    Image.asset(
                      'lib/assets/images/bazario-logo.png',
                      width: 120,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Featured Events",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDD602D),
                            ),
                          ),
                          GestureDetector(
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
                                boxShadow: null,
                                color: const Color(0xFFFFD800),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE4C100),
                                  width: 2,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    SolarIconsBold.cart,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildCarousel(),
                  ],
                ),
              ),
            ),
            // --- Categories Section ---
            Positioned(
              top: 325,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: const Text(
                        "CATEGORIES",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Color(0xFF74CC00),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          // First Row: FOOD + ESSENTIALS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCategoryBox(
                                bgImage: 'lib/assets/images/cat_food.png',
                                strokeColor: const Color(0xFFFF9E17),
                                icon: const Iconify(
                                  Mdi.food,
                                  color: Color(0xFFFF9E17),
                                  size: 60,
                                ),
                                label: 'FOOD',
                                labelColor: const Color(0xFFFF9E17),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShoppingScreen(
                                        category: 'food',
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildCategoryBox(
                                bgImage: 'lib/assets/images/cat_essentials.png',
                                strokeColor: const Color(0xFF569109),
                                icon: const Icon(
                                  SolarIconsBold.perfume,
                                  color: Color(0xFF569109),
                                  size: 60,
                                ),
                                label: 'ESSENTIALS',
                                labelColor: const Color(0xFF569109),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShoppingScreen(
                                        category: 'essentials',
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Second Row: ALL + WEARABLES
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCategoryBox(
                                bgImage: 'lib/assets/images/cat_all.png',
                                strokeColor: const Color(0xFF045DC4),
                                icon: const Iconify(
                                  MaterialSymbols.category_rounded,
                                  color: Color(0xFF045DC4),
                                  size: 60,
                                ),
                                label: 'ALL',
                                labelColor: const Color(0xFF045DC4),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShoppingScreen(
                                        category: 'all',
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildCategoryBox(
                                bgImage: 'lib/assets/images/cat_wearables.png',
                                strokeColor: const Color(0xFFDD602D),
                                icon: const Iconify(
                                  Maki.jewelry_store,
                                  color: Color(0xFFDD602D),
                                  size: 60,
                                ),
                                label: 'WEARABLES',
                                labelColor: const Color(0xFFDD602D),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShoppingScreen(
                                        category: 'wearables',
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- Browse Mode Notice (anchored bottom) ---
            if (isBrowseMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBrowseModeNotice(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Carousel builder
  Widget _buildCarousel() {
    final items = [
      // First slide: What's Hot
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          boxShadow: null,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF7482B), width: 2),
          image: const DecorationImage(
            image: AssetImage('lib/assets/images/whats-hot-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              // Stroke layer
              Text(
                "What's Hot?!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1
                    ..color = const Color(0xFFF7482B),
                ),
              ),
              // Fill layer
              const Text(
                "What's Hot?!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFFDD602D),
                ),
              ),
            ],
          ),
        ),
      ),
      // Event posters
      ..._eventBanners.map((bannerPath) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            boxShadow: null,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF7482B), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              bannerPath,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported)),
                );
              },
            ),
          ),
        );
      }).toList(),
    ];

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 120,
            child: CarouselSlider(
              items: items.map((item) {
                return FractionallySizedBox(widthFactor: 0.9, child: item);
              }).toList(),
              options: CarouselOptions(
                height: 120,
                enlargeCenterPage: true,
                autoPlay: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final isActive = _currentIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 30 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFF7482B)
                    : const Color(0xFFF7482B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryBox({
    required String bgImage,
    required Color strokeColor,
    required Widget icon,
    required String label,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: strokeColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 1,
              inset: true,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image layer
              Positioned.fill(child: Image.asset(bgImage, fit: BoxFit.cover)),
              // White overlay layer (70% opacity)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              // Content layer (icon and text)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: labelColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Browse Mode Notice reused
  Widget _buildBrowseModeNotice(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBrowseModeDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF9E17)),
        ),
        child: const Text(
          "Browse mode: Log in to purchase or interact with items.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF856404)),
        ),
      ),
    );
  }

  void _showBrowseModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log In Required'),
        content: const Text('Please log in to access Shop features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF74CC00),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
