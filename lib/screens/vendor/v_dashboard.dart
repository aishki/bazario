import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'v_my_shop_screen.dart';
import 'v_my_docs_screen.dart';
import 'v_pop_ups_screen.dart';
import 'v_notifs_screen.dart';
import '../../models/vendor.dart';
import '../../components/vendor_navbar.dart';

class VendorDashboard extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final String? logoUrl;
  final Vendor vendor;

  const VendorDashboard({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.vendor,
    required this.businessName,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Debug print for Vendor
    debugPrint("[VendorDashboard] Current Vendor: ${vendor.toJson()}");

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/images/dashboard-bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 50,
          left: 16,
          right: 16,
          bottom: 100, // Space for bottom navigation
        ),
        child: Column(
          children: [
            // Header profile container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8685B), width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Profile image
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
                            vendor.logoUrl != null && vendor.logoUrl!.isNotEmpty
                            ? NetworkImage(vendor.logoUrl!)
                            : const AssetImage("lib/assets/images/logo_img.jpg")
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Greeting and Business Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Maayong Adlaw!",
                          style: const TextStyle(
                            fontFamily: 'Starla',
                            fontSize: 16,
                            color: Color(0xFFFF390F),
                          ),
                        ),
                        Text(
                          businessName,
                          style: const TextStyle(
                            fontFamily: 'Starla',
                            fontSize: 20,
                            color: Color(0xFFE8685B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Dashboard flex boxes
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDashboardBox(
                  context,
                  color: const Color(0xFFF9FFBA), // Yellow
                  borderColor: const Color(0xFFFFD400),
                  imagePath: "lib/assets/images/my-shop-banner.png",
                  label: "My Shop",
                  page: VendorMyShop(
                    vendor: vendor,
                    userId: userId,
                    vendorId: vendorId,
                    businessName: businessName,
                  ),
                ),
                _buildDashboardBox(
                  context,
                  color: const Color(0xFFD8FEA5), // Green
                  borderColor: const Color(0xFF74CC00),
                  imagePath: "lib/assets/images/pop-ups-banner.png",
                  label: "Pop-ups",
                  page: VendorPopUps(
                    userId: userId,
                    vendorId: vendorId,
                    businessName: businessName,
                    vendor: vendor,
                  ),
                ),
                _buildDashboardBox(
                  context,
                  color: const Color(0xFFBEDCFF), // Blue
                  borderColor: const Color(0xFF045DC4),
                  imagePath: "lib/assets/images/my-docs-banner.png",
                  label: "My Docs",
                  page: VendorMyDocs(
                    userId: userId,
                    vendorId: vendorId,
                    businessName: businessName,
                    vendor: vendor,
                  ),
                ),
                _buildDashboardBox(
                  context,
                  color: const Color(0xFFFFD498), // Orange
                  borderColor: const Color(0xFFFF9E17),
                  imagePath: "lib/assets/images/notifs-banner.png",
                  label: "Notifs",
                  page: VendorNotifs(
                    userId: userId,
                    vendorId: vendorId,
                    businessName: businessName,
                    vendor: vendor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBox(
    BuildContext context, {
    required Color color,
    required Color borderColor,
    required String imagePath,
    required String label,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Banner Image with border
            Container(
              width: 115,
              height: 84,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // SVG Icon (with color from border)
            SvgPicture.asset(
              "lib/assets/icons/play-circle.svg",
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
            ),

            // Divider line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Divider(thickness: 1.5, color: borderColor),
            ),

            // Title
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Bagel Fat One', // from assets/fonts
                fontSize: 20,
                color: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
