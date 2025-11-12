import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/prime.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../models/vendor_product.dart';
import '../../services/vendor_service.dart';
import '../../models/vendor.dart';

class CMerchantsProfilePage extends StatelessWidget {
  final Vendor vendor;
  final VendorService _vendorService = VendorService();
  CMerchantsProfilePage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // ✅ ensures background covers the full screen
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/merchants-profile-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 7),

                // Rounded info box
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBFFD1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 4), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FIRST ROW ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                image:
                                    (vendor.logoUrl != null &&
                                        vendor.logoUrl!.isNotEmpty)
                                    ? NetworkImage(vendor.logoUrl!)
                                    : const AssetImage(
                                            "lib/assets/images/default_profile.jpg",
                                          )
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 45),

                          // Business name + socials
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor.businessName ?? "Unknown",
                                  style: const TextStyle(
                                    fontFamily: 'Starla',
                                    fontSize: 18,
                                    color: Color(0xFF276700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._buildSocials(vendor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF569109)),
                      const SizedBox(height: 8),

                      // --- SECOND ROW: Description ---
                      Text(
                        vendor.description ?? "No description available.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF276700),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // 🟡 TOP PRODUCTS SECTION
                FutureBuilder<List<VendorProduct>>(
                  future: _vendorService.getTopProducts(
                    vendor.id,
                  ), // adjust according to your Vendor model
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.inkDrop(
                          color: const Color(0xFFDD602D),
                          size: 50,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Failed to load products."),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 👻 Ghost gif
                            Image.asset(
                              "lib/assets/icons/empty_ghost.gif",
                              height: 150,
                            ),

                            Text(
                              "No top products yet.",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      );
                    }

                    final products = snapshot.data!;
                    int currentIndex = 0;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        final product = products[currentIndex];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 70),

                            // 🖼️ PRODUCT IMAGE + ARROWS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Left arrow
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex =
                                          (currentIndex - 1 + products.length) %
                                          products.length;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFFFF9E17),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Iconify(
                                      Gg.arrow_left_r,
                                      color: Color(0xFFFFD400),
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Stack: Product image + banner overlay
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Product image
                                    Container(
                                      width: 210,
                                      height: 190,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFFFD800),
                                          width: 4,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            product.imageUrl ??
                                                "https://via.placeholder.com/224x200",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    // Top-left banner overlay
                                    Positioned(
                                      top: -50,
                                      left: -70,
                                      child: Image.asset(
                                        "lib/assets/images/top-product-banner.png",
                                        width: 170, // adjust as needed
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),

                                // Right arrow
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex =
                                          (currentIndex + 1) % products.length;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color(0xFFFF9E17),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Iconify(
                                      Gg.arrow_right_r,
                                      color: Color(0xFFFFD400),
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // 🧾 Product description box
                            Container(
                              height: 108,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF569109),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x88569109),
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    inset: true, // inner shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name ?? "Unnamed Product",
                                    style: const TextStyle(
                                      fontFamily: "Starla",
                                      fontSize: 14,
                                      color: Color(0xFF276700),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 🌀 Scrollable description text
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        product.description ??
                                            "No description provided.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF276700),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 🟢 Bazario logo at the bottom
                            Image.asset(
                              "lib/assets/images/bazario-logo.png",
                              width: 86,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// helper to build socials based on preferences
  List<Widget> _buildSocials(Vendor vendor) {
    final prefs = vendor.contactDisplayPreferences;
    final links = vendor.socialLinks;

    final List<Widget> socials = [];

    void addSocial(bool show, Widget icon, String? text) {
      if (show) {
        socials.add(
          Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                text?.isNotEmpty == true ? text! : "Not added yet",
                style: const TextStyle(fontSize: 14, color: Color(0xFF569109)),
              ),
            ],
          ),
        );
        socials.add(const SizedBox(height: 4));
      }
    }

    addSocial(
      prefs.showInstagram,
      const Iconify(Mdi.instagram, color: Color(0xFF276700), size: 18),
      links.instagram,
    );

    addSocial(
      prefs.showFacebook,
      const Icon(Icons.facebook, color: Color(0xFF276700), size: 18),
      links.facebook,
    );

    addSocial(
      prefs.showPhone,
      const Icon(Icons.phone, color: Color(0xFF276700), size: 18),
      vendor.contact?.phoneNumber,
    );

    addSocial(
      prefs.showWebsite,
      const Iconify(Prime.globe, color: Color(0xFF276700), size: 18),
      links.website,
    );

    addSocial(
      prefs.showTiktok,
      const Iconify(Ic.baseline_tiktok, color: Color(0xFF276700), size: 18),
      links.tiktok,
    );

    addSocial(
      prefs.showTwitter,
      const Iconify(Prime.twitter, color: Color(0xFF276700), size: 18),
      links.twitter,
    );

    return socials;
  }
}
