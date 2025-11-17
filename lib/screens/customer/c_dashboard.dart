import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../models/customer.dart';
import '../../models/vendor.dart';
import '../../models/vendor_product.dart';
import '../../services/vendor_service.dart';
import '../../services/auth_service.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../login_screen.dart';
import 'c_merchants_profile.dart';
import 'c_settings_screen.dart';
import 'c_notifications_screen.dart'; // Import the notifications screen

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
  Customer? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _loadVendorsWithRandomImages();
    currentUser = widget.customer; // Initialize currentUser
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

  Stream<int> _getUnreadNotificationCount() {
    // Placeholder for the actual stream that fetches unread notification count
    return Stream.fromIterable([0, 1, 2, 3]);
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
                  flex: 7,
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
                                        fontSize: 18,
                                        color: Color(0xFFE8685B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate long names
                                      softWrap:
                                          false, // Prevents wrapping to the next line
                                    ),
                                  ],
                                ),
                              ),

                              // 📱 Notification + Menu Row
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🔔 Notification Icon
                                  StreamBuilder<int>(
                                    stream: _getUnreadNotificationCount(),
                                    builder: (context, snapshot) {
                                      final unreadCount = snapshot.data ?? 0;
                                      return Stack(
                                        children: [
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CNotificationsScreen(
                                                        customerId:
                                                            currentUser!.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(0),
                                              child: Icon(
                                                Icons.notifications,
                                                color: Color(0xFFB0BEC5),
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                          if (unreadCount > 0)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 9,
                                                height: 9,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFF4444,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 4),

                                  // ⋮ Three-dot Menu (Custom Popup)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {
                                      final RenderBox overlay =
                                          Overlay.of(
                                                context,
                                              ).context.findRenderObject()
                                              as RenderBox;

                                      final selectedValue = await showMenu<String>(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          overlay.size.width -
                                              10, // adjust horizontal position
                                          kToolbarHeight +
                                              35, // slightly tighter vertical offset
                                          8,
                                          0,
                                        ),
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE0E0E0),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 6,
                                        items: [
                                          PopupMenuItem(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ), // 👈 tighter padding
                                            height: 30, // 👈 reduce height
                                            value: 'settings',
                                            child: Row(
                                              mainAxisSize: MainAxisSize
                                                  .min, // 👈 prevent stretching full width
                                              children: const [
                                                Icon(
                                                  Icons.settings,
                                                  color: Color(0xFF424242),
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Settings',
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF424242),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuDivider(height: 6),
                                          PopupMenuItem(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            height: 30,
                                            value: 'logout',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.logout,
                                                  color: Color(0xFFD32F2F),
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Log Out',
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFD32F2F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );

                                      // 🎯 Handle menu actions
                                      if (selectedValue == 'settings') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Settings coming soon!",
                                            ),
                                          ),
                                        );
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         SettingsScreen(
                                        //           customerId:
                                        //               widget.customerId ?? '',
                                        //         ),
                                        //   ),
                                        // );
                                      } else if (selectedValue == 'logout') {
                                        await AuthService().logout();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Logged out successfully',
                                              ),
                                              backgroundColor: Color(
                                                0xFF06851D,
                                              ),
                                            ),
                                          );
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Color(0xFFB0BEC5),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

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
                                    height: 170,
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
                                      children: List.generate(3, (colIndex) {
                                        return Container(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.28,
                                          height:
                                              (MediaQuery.of(
                                                context,
                                              ).size.height) /
                                              2 *
                                              0.33,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Check our Merchants!",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Starla',
                                      fontSize: 22,
                                      color: Color(0xFFFF390F),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Feature coming soon! ✨",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                              backgroundColor: Color(
                                                0xFFF22031,
                                              ),
                                            ),
                                          );
                                        },
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

                                      const SizedBox(height: 5),
                                      const Text(
                                        // Bigger font
                                        "Be one of us!",
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontFamily: 'Poppins',
                                          fontSize: 8,
                                          color: Color(0xFF276700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // 🧭 Paginated Merchant Grid
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return PageView.builder(
                                      controller: _pageController,
                                      onPageChanged: (index) =>
                                          setState(() => _currentPage = index),
                                      itemCount: (vendors.length / 6)
                                          .ceil(), // 6 per page
                                      itemBuilder: (_, pageIndex) {
                                        final start = pageIndex * 6;
                                        final end = (start + 6).clamp(
                                          0,
                                          vendors.length,
                                        );
                                        final pageVendors = vendors.sublist(
                                          start,
                                          end,
                                        );

                                        return GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 5,
                                          ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3, // 3 columns
                                                mainAxisSpacing: 12,
                                                crossAxisSpacing: 12,
                                                mainAxisExtent:
                                                    constraints.maxHeight *
                                                    0.44, // 44% of grid height per card
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
                                              child: SizedBox(
                                                child: _buildMerchantCard(
                                                  vendor,
                                                ),
                                              ),
                                            );
                                          },
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
                                  (vendors.length / 6).ceil(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(Vendor vendor) {
    final imageUrl = vendorBgImages[vendor.id];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight =
            constraints.maxHeight * 0.9; // responsive to grid cell height

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: GestureDetector(
            onTapDown: (_) => setState(() {}), // to allow visual feedback
            onTapUp: (_) => setState(() {}), // reset after tap
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CMerchantsProfilePage(vendor: vendor),
                ),
              );
            },
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: double.infinity,
                height: cardHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF390F), width: 3),
                  borderRadius: BorderRadius.circular(10),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color.fromARGB(
                              255,
                              120,
                              34,
                              17,
                            ).withOpacity(0.55),
                            BlendMode.darken,
                          ),
                        )
                      : DecorationImage(
                          image: AssetImage(
                            'lib/assets/images/vendor-placeholder.jpg',
                          ),
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
              ),
            ),
          ),
        );
      },
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
                height: 115, //featured height
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
                        height: 130,
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
