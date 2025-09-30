import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/vendor/v_announcements_screen.dart';
import '../screens/vendor/v_profile_screen.dart';
import '../screens/vendor/v_dashboard.dart';
import '../models/vendor.dart';

class VendorNavBar extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorNavBar({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  State<VendorNavBar> createState() => _VendorNavBarState();
}

class _VendorNavBarState extends State<VendorNavBar> {
  int _currentIndex = 1; // Default to Home

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const VendorAnnouncementsScreen(),
      VendorDashboard(
        userId: widget.userId,
        vendorId: widget.vendorId,
        businessName: widget.businessName,
        vendor: widget.vendor,
      ),
      VendorProfileScreen(
        userId: widget.userId,
        vendorId: widget.vendorId,
        businessName: widget.businessName,
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Instead, minimize the app or show exit confirmation
        if (_currentIndex != 1) {
          // If not on home screen, go to home screen
          setState(() {
            _currentIndex = 1;
          });
          return false;
        } else {
          // If on home screen, show exit confirmation
          return await _showExitConfirmation(context) ?? false;
        }
      },
      child: Scaffold(
        extendBody: true,
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildCustomNavBar(),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomNavBar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Bottom White Background
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. Ellipse SVG that animates to active item
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _getEllipseX(screenWidth),
            top: 0,
            child: SvgPicture.asset("lib/assets/icons/ellipse.svg", height: 60),
          ),

          // 3. Icons Row (3 equal columns)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: _buildNavIcon(
                      "lib/assets/icons/notif.svg",
                      isActive: _currentIndex == 0,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: _buildNavIcon(
                      "lib/assets/icons/home.svg",
                      isActive: _currentIndex == 1,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: _buildNavIcon(
                      "lib/assets/icons/profile.svg",
                      isActive: _currentIndex == 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dynamically calculate ellipse X position per active state
  double _getEllipseX(double screenWidth) {
    switch (_currentIndex) {
      //lower = to the left ; higher = move right
      case 0: // Notifications
        return 0.5;
      case 1: // Home
        return screenWidth / 2 - 59.5;
      case 2: // Profile
        return screenWidth / 2 + 60.5;
      default:
        return screenWidth / 2 - 59.5;
    }
  }

  Widget _buildNavIcon(String asset, {required bool isActive}) {
    return Container(
      width: 47,
      height: 45,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          colorFilter: ColorFilter.mode(
            isActive ? const Color(0xFFF57A60) : const Color(0xFFFF9E17),
            BlendMode.srcIn,
          ),
          width: 26,
        ),
      ),
    );
  }
}
