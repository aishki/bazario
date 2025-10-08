import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/customer.dart';
import '../screens/customer/c_dashboard.dart';
import '../screens/customer/c_shop.dart';

class CustomerNavBar extends StatefulWidget {
  final String userId;
  final String customerId;
  final String username;
  final Customer customer;
  const CustomerNavBar({
    super.key,
    required this.userId,
    required this.customerId,
    required this.username,
    required this.customer,
  });

  @override
  State<CustomerNavBar> createState() => _CustomerNavBarState();
}

class _CustomerNavBarState extends State<CustomerNavBar> {
  int _currentIndex = 1; // Default to Home

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      CustomerShop(),
      CustomerDashboard(
        userId: widget.userId,
        username: widget.username,
        customer: widget.customer,
      ),
      const Center(child: Text("Shop Page")),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 1) {
          setState(() => _currentIndex = 1);
          return false;
        } else {
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
          // White background with rounded top corners
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

          // Ellipse indicator animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _getEllipseX(screenWidth),
            top: 0,
            child: SvgPicture.asset(
              "lib/assets/icons/c_ellipse.svg",
              height: 60,
            ),
          ),

          // Navigation icons
          Positioned.fill(
            child: Row(
              children: [
                // Cart
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: _buildNavIcon(
                      icon: const Icon(SolarIconsBold.cart),
                      isActive: _currentIndex == 0,
                    ),
                  ),
                ),

                // Home
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: _buildNavIcon(
                      svgAsset: "lib/assets/icons/home.svg",
                      isActive: _currentIndex == 1,
                    ),
                  ),
                ),

                // Shop
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: _buildNavIcon(
                      icon: Icon(SolarIconsBold.shop),
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

  // Ellipse position logic
  double _getEllipseX(double screenWidth) {
    switch (_currentIndex) {
      case 0:
        return 0.5;
      case 1:
        return screenWidth / 2 - 59.5;
      case 2:
        return screenWidth / 2 + 60.5;
      default:
        return screenWidth / 2 - 59.5;
    }
  }

  Widget _buildNavIcon({
    Widget? icon,
    String? svgAsset,
    required bool isActive,
  }) {
    return Container(
      width: 47,
      height: 45,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFFF57A60) : const Color(0xFFFF9E17),
                  BlendMode.srcIn,
                ),
                width: 26,
              )
            : IconTheme(
                data: IconThemeData(
                  color: isActive
                      ? const Color(0xFFF57A60)
                      : const Color(0xFFFF9E17),
                  size: 30,
                ),
                child: icon!,
              ),
      ),
    );
  }
}
