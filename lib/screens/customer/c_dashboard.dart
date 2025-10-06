import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../login_screen.dart';
import '../../models/customer.dart';
import '../../models/vendor.dart';
import '../../models/vendor_product.dart';
import '../../services/vendor_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'c_merchants_profile.dart'; // for merchant profile navigation

class CustomerDashboard extends StatefulWidget {
  final String? userId;
  final String? email;
  final String? username;
  final String? customerId;
  final Customer? customer;
  final bool isBrowseMode;

  const CustomerDashboard({
    super.key,
    this.userId,
    this.email,
    this.username,
    this.customerId,
    this.customer,
    this.isBrowseMode = false,
  });

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<String> carouselImages = [];
  List<Vendor> vendors = [];
  final VendorService _vendorService = VendorService();
  final Map<String, String?> vendorBgImages = {};
  bool isLoadingMerchants = true;
  List<VendorProduct> featuredProducts = [];
  bool isLoadingCarousel = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedCategory;
  final List<String> _categories = ['Food', 'Clothing', 'Crafts', 'Others'];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _loadVendorsWithRandomImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCarouselImages() async {
    try {
      // Here we just get random products from all vendors
      final vendors = await _vendorService.getVendors();
      final allProducts = <VendorProduct>[];

      for (var vendor in vendors) {
        final products = await _vendorService.getTopProducts(vendor.id);
        allProducts.addAll(products);
      }

      // Shuffle and pick up to 7 random ones
      allProducts.shuffle();
      final randomProducts = allProducts.take(7).toList();

      setState(() {
        featuredProducts = randomProducts;
        isLoadingCarousel = false;
      });
    } catch (e) {
      debugPrint('Error loading carousel images: $e');
      setState(() {
        isLoadingCarousel = false;
      });
    }
  }

  Future<void> _loadVendorsWithRandomImages() async {
    try {
      final fetchedVendors = await _vendorService.getVendors();

      for (var vendor in fetchedVendors) {
        final products = await _vendorService.getTopProducts(vendor.id);
        if (products.isNotEmpty) {
          products.shuffle(); // randomize order
          vendorBgImages[vendor.id] = products.first.imageUrl; // pick one
        } else {
          vendorBgImages[vendor.id] = null; // fallback if no products
        }
      }

      setState(() {
        vendors = fetchedVendors;
        isLoadingMerchants = false;
      });
    } catch (e) {
      debugPrint('Error loading merchants: $e');
      setState(() {
        isLoadingMerchants = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final isBrowseMode = widget.isBrowseMode;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/images/explore-bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // 🌿 MAIN PAGE CONTENT
            Column(
              children: [
                // 🧩 TOP SECTION
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // HEADER PROFILE CONTAINER
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFE8685B),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Profile Image
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE8685B),
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image:
                                        (customer?.profileUrl != null &&
                                            customer!.profileUrl!.isNotEmpty)
                                        ? NetworkImage(customer.profileUrl!)
                                        : const AssetImage(
                                                "lib/assets/images/default_profile.jpg",
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Greeting + Username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Maayong Adlaw!",
                                      style: TextStyle(
                                        fontFamily: 'Starla',
                                        fontSize: 16,
                                        color: Color(0xFFFF390F),
                                      ),
                                    ),
                                    Text(
                                      widget.username ?? "Guest",
                                      style: const TextStyle(
                                        fontFamily: 'Starla',
                                        fontSize: 20,
                                        color: Color(0xFFE8685B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //Profile Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  backgroundColor: const Color(0xFFFFD800),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Color(0xFFFF9E17),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Clicked. Hehe'),
                                      backgroundColor: Color(0xFF06851D),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "View Profile",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 2 BUTTONS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 112,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD800),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Color(0xFFFF9E17),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (isBrowseMode) {
                                    _showBrowseModeDialog(context, "Shop");
                                  } else {
                                    Navigator.pushNamed(context, '/c_shop');
                                  }
                                },
                                child: const Text(
                                  "Shop Now",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF74CC00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                      color: Color(0xFF5DA400),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (isBrowseMode) {
                                    _showBrowseModeDialog(context, "Events");
                                  } else {
                                    Navigator.pushNamed(context, '/c_events');
                                  }
                                },
                                child: const Text(
                                  "Show Events",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🌿 FEATURED PRODUCTS CAROUSEL (local loading state)
                        if (featuredProducts.isNotEmpty)
                          FeaturedProductsCarousel(
                            products: featuredProducts,
                            onProductTap: (product) async {
                              final vendor = await _vendorService
                                  .getVendorProfile(product.vendorId ?? '');
                              if (vendor != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CMerchantsProfilePage(vendor: vendor),
                                  ),
                                );
                              }
                            },
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (index) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.27,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 🧩 BOTTOM SECTION
                Expanded(
                  flex: 8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FFBA).withOpacity(0.7),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFFFD800), width: 6),
                      ),
                    ),
                    child: isLoadingMerchants
                        ? Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Column(
                                children: List.generate(2, (rowIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(4, (colIndex) {
                                        return Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.18,
                                          height: 95,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              // 🏷️ Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Check our Merchants!",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Starla',
                                      fontSize: 15,
                                      color: Color(0xFFFF390F),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        "Be one of us!",
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontFamily: 'Poppins',
                                          fontSize: 8,
                                          color: Color(0xFF276700),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showJoinUsDialog(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFF22031,
                                            ).withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            "JOIN US",
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontFamily: 'Starla',
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // 🧭 Paginated Merchant Grid
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) =>
                                      setState(() => _currentPage = index),
                                  itemCount: (vendors.length / 8).ceil(),
                                  itemBuilder: (_, pageIndex) {
                                    final start = pageIndex * 8;
                                    final end = (start + 8).clamp(
                                      0,
                                      vendors.length,
                                    );
                                    final pageVendors = vendors.sublist(
                                      start,
                                      end,
                                    );

                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisExtent: 95,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      itemCount: pageVendors.length,
                                      itemBuilder: (context, index) {
                                        final vendor = pageVendors[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CMerchantsProfilePage(
                                                      vendor: vendor,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: _buildMerchantCard(vendor),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              // 🔘 Page Indicators
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  (vendors.length / 8).ceil(),
                                  (index) {
                                    final isActive = _currentPage == index;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(3),
                                        color: isActive
                                            ? const Color(0xFFFF2C00)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: const Color(0xFFFF2C00),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            // 🌀 GLOBAL OVERLAY LOADER (covers both sections)
            if (isLoadingCarousel || isLoadingMerchants)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: const Color(0xFFDD602D),
                    size: 60,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(Vendor vendor) {
    final imageUrl = vendorBgImages[vendor.id];

    return Container(
      width: 336,
      height: 95,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF390F), width: 3),
        borderRadius: BorderRadius.circular(10),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 120, 34, 17).withOpacity(0.55),
                  BlendMode.darken,
                ),
              )
            : DecorationImage(
                image: AssetImage('lib/assets/images/vendor-placeholder.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color.fromARGB(255, 120, 34, 17).withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
      ),
      child: Center(
        child: Text(
          vendor.businessName.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _styledField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins-Medium',
              fontSize: 13,
              color: Color(0xFFDD602D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(99, 221, 95, 45)),
            ),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              maxLines: maxLines,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Color(0xFF792401),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Color(0xFFDD602D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(width: 400, height: 550),
          ),
        );
      },
    );
  }

  void _showBrowseModeDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log In Required'),
          content: Text(
            'Please log in to access $feature and use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74CC00),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Log In',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeaturedProductsCarousel extends StatefulWidget {
  final List<VendorProduct> products;
  final Function(VendorProduct) onProductTap;

  const FeaturedProductsCarousel({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<FeaturedProductsCarousel> createState() =>
      _FeaturedProductsCarouselState();
}

class _FeaturedProductsCarouselState extends State<FeaturedProductsCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    final products = widget.products.take(5).toList();

    return Column(
      children: [
        const SizedBox(height: 25),
        const Text(
          "Featured Products",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontFamily: 'Starla',
            fontSize: 17,
            color: Color(0xFF74CC00),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),

        // 🧩 Stack for carousel + banner
        Stack(
          clipBehavior: Clip.none, // ensures banner can overflow
          children: [
            // 🖼️ Carousel
            CarouselSlider.builder(
              itemCount: products.length,
              carouselController: _controller,
              options: CarouselOptions(
                height: 120, //featured height
                viewportFraction: 0.33,
                enlargeCenterPage: true,
                enlargeFactor: 0.18,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final product = products[index];
                final isActive = index == _current;

                return GestureDetector(
                  onTap: () => widget.onProductTap(product),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF5DA400),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl ?? "",
                        width: 110,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 🔥 “What’s Hot” banner
            Positioned(
              top: -50, // adjust upward overlap
              left: -10, // adjust horizontal position
              child: Image.asset(
                'lib/assets/images/whats-hot-banner.png',
                width: 110, // adjust to match design
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 🔘 Indicator Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: products.asMap().entries.map((entry) {
            final isActive = _current == entry.key;
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? const Color(0xFF74CC00)
                      : Colors.transparent,
                  border: Border.all(color: const Color(0xFF74CC00), width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
