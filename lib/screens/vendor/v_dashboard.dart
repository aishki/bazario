import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'v_my_shop_screen.dart';
import 'v_my_docs_screen.dart';
import 'v_pop_ups_screen.dart';
import 'v_notifs_screen.dart';
import '../login_screen.dart';
import '../../models/vendor.dart';
import '../../services/vendor_service.dart';
import '../../services/auth_service.dart';
import '../../services/tutorial_service.dart';

class VendorDashboard extends StatefulWidget {
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
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  Vendor? _currentVendor;
  final _vendorService = VendorService();
  bool _isLoading = true;

  final List<GlobalKey> _tutorialKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _checkTutorialStatus() async {
    final seen = await TutorialService.hasSeenTutorial('dashboard');
    if (!seen && mounted) {
      _showSpotlightTutorial(0);
    }
  }

  final List<Map<String, String>> _tutorialSteps = [
    {
      "message":
          "Tap here to view your shop details and edit your featured products.",
    },
    {"message": "Tap here to view and join upcoming pop ups as a vendor!"},
    {
      "message":
          "Tap here to upload your documents and become a verified vendor.\nVendor verification will help you secure a spot in pop-up events!",
    },
    {"message": "Tap here to view your notifications."},
  ];
  void _showSpotlightTutorial(int index) {
    if (index >= _tutorialSteps.length) {
      _showDisableDialog();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _tutorialKeys[index].currentContext?.findRenderObject() as RenderBox?;

      if (renderBox == null) {
        debugPrint("[Tutorial] RenderBox is null for index $index");
        return;
      }

      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      final screenSize = MediaQuery.of(context).size;

      debugPrint("[Tutorial] Box $index - Offset: $offset, Size: $size");

      // 💡 Move the adjustment logic (before showDialog)
      Offset adjustedOffset = offset;
      Size adjustedSize = size;

      switch (index) {
        //moving up: closer to negative, down: closer to positive, left: closer to negative, right: closer to positive
        case 0: // My Shop
          // adjustedOffset = offset.translate(4, -39); // Move slightly left/up
          adjustedOffset = offset.translate(4, -25); //dale
          // adjustedOffset = offset.translate(4, -41); //PC Demo
          adjustedSize = Size(size.width, size.height);
          break;
        case 1: // Pop-Ups
          // adjustedOffset = offset.translate(4, -39); // Move slightly right/up
          adjustedOffset = offset.translate(4, -25); //dale
          // adjustedOffset = offset.translate(4, -41); //PC Demo

          adjustedSize = Size(size.width, size.height);
          break;
        case 2: // My Docs
          // adjustedOffset = offset.translate(4, -39); // Move left/down
          adjustedOffset = offset.translate(4, -25); //dale
          // adjustedOffset = offset.translate(4, -41); //PC Demo

          adjustedSize = Size(size.width, size.height);
          break;
        case 3: // Notifs
          // adjustedOffset = offset.translate(4, -39); // Move right/down
          adjustedOffset = offset.translate(4, -25); //dale
          // adjustedOffset = offset.translate(4, -41); //PC Demo
          adjustedSize = Size(size.width, size.height);
          break;
      }

      // Position the dialog box
      double dialogLeft;
      double dialogTop;

      switch (index) {
        case 0:
          dialogLeft = 16;
          dialogTop = screenSize.height - 380;
          // dialogTop = screenSize.height - 500; //gene
          break;
        case 1:
          dialogLeft = screenSize.width - 256;
          dialogTop = screenSize.height - 380;
          // dialogTop = screenSize.height - 500; //gene
          break;
        case 2:
          dialogLeft = 16;
          dialogTop = 120;
          break;
        case 3:
          dialogLeft = screenSize.width - 256;
          dialogTop = 140;
          break;
        default:
          dialogLeft = screenSize.width / 2 - 120;
          dialogTop = screenSize.height / 2 - 90;
      }

      debugPrint(
        "[Tutorial] Dialog position - Left: $dialogLeft, Top: $dialogTop",
      );

      // Now show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // Prevent outside tap
                  child: CustomPaint(
                    painter: SpotlightPainter(
                      offset: adjustedOffset,
                      size: adjustedSize,
                      spotlightRadius: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: dialogLeft,
                top: dialogTop,
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD400),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "💡 Tutorial Tip",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF792401),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tutorialSteps[index]["message"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A2401),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showSpotlightTutorial(index + 1);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF792401),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showDisableDialog();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: const BorderSide(
                                  color: Color(0xFFFFD400),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              "Skip",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF792401),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFD400), width: 2),
          ),
          backgroundColor: const Color(0xFFFFF7E6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Tutorial Complete! 🎉",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF792401),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Would you like to disable the tutorial on your next visit?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xFF5A2401),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await TutorialService.setHasSeenTutorial(
                          'dashboard',
                          true,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Yes, disable",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Color(0xFF792401),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFFFD400),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Keep It",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Color(0xFF792401),
                          fontWeight: FontWeight.bold,
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

  Future<void> _loadVendorData() async {
    try {
      final vendorData = await _vendorService.getVendorProfile(widget.vendorId);
      if (vendorData != null && mounted) {
        setState(() {
          _currentVendor = vendorData;
          _isLoading = false;
          _checkTutorialStatus();
        });
      }
    } catch (e) {
      debugPrint("[VendorDashboard] Error loading vendor data: $e");
      setState(() => _isLoading = false);
      _checkTutorialStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = _currentVendor ?? widget.vendor;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/dashboard-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? _buildShimmerLoading(context)
            : _buildDashboardContent(context, vendor),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 50,
        left: 16,
        right: 16,
        bottom: 100,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8685B), width: 4),
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                4,
                (index) => Container(
                  width: 150,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, width: 3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Vendor vendor) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 50,
        left: 16,
        right: 16,
        bottom: 100,
      ),
      child: Column(
        children: [
          _buildHeader(vendor),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDashboardBox(
                context,
                key: _tutorialKeys[0],
                color: const Color(0xFFF9FFBA),
                borderColor: const Color(0xFFFFD400),
                imagePath: "lib/assets/images/my-shop-banner.png",
                label: "My Shop",
                page: VendorMyShop(
                  vendor: vendor,
                  userId: widget.userId,
                  vendorId: widget.vendorId,
                  businessName: widget.businessName,
                ),
              ),
              _buildDashboardBox(
                context,
                key: _tutorialKeys[1],
                color: const Color(0xFFD8FEA5),
                borderColor: const Color(0xFF74CC00),
                imagePath: "lib/assets/images/pop-ups-banner.png",
                label: "Pop-ups",
                page: VendorPopUps(
                  userId: widget.userId,
                  vendorId: widget.vendorId,
                  businessName: widget.businessName,
                  vendor: vendor,
                ),
              ),
              _buildDashboardBox(
                context,
                key: _tutorialKeys[2],
                color: const Color(0xFFBEDCFF),
                borderColor: const Color(0xFF045DC4),
                imagePath: "lib/assets/images/my-docs-banner.png",
                label: "My Docs",
                page: VendorMyDocs(
                  userId: widget.userId,
                  vendorId: widget.vendorId,
                  businessName: widget.businessName,
                  vendor: vendor,
                ),
              ),
              _buildDashboardBox(
                context,
                key: _tutorialKeys[3],
                color: const Color(0xFFFFD498),
                borderColor: const Color(0xFFFF9E17),
                imagePath: "lib/assets/images/notifs-banner.png",
                label: "Notifs",
                page: VendorNotificationScreen(
                  userId: widget.userId,
                  vendorId: widget.vendorId,
                  businessName: widget.businessName,
                  vendor: vendor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Vendor vendor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8685B), width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8685B), width: 2),
              image: DecorationImage(
                image: vendor.logoUrl != null && vendor.logoUrl!.isNotEmpty
                    ? NetworkImage(vendor.logoUrl!)
                    : const AssetImage("lib/assets/images/default_profile.jpg")
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Starla',
                          fontSize: 20,
                          color: Color(0xFFE8685B),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showMenu,
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
        ],
      ),
    );
  }

  void _showMenu() async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 10,
        kToolbarHeight + 35,
        8,
        0,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      elevation: 6,
      items: [
        const PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFF424242)),
              SizedBox(width: 8),
              Text(
                'About Us',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 6),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: Color(0xFFD32F2F)),
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
    if (selectedValue == 'about') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature coming soon'),
            backgroundColor: Color(0xFF424242),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (selectedValue == 'logout') {
      await AuthService().logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Color(0xFF06851D),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDashboardBox(
    BuildContext context, {
    Key? key,
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
        key: key,
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
            SvgPicture.asset(
              "lib/assets/icons/play-circle.svg",
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Divider(thickness: 1.5, color: borderColor),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Bagel Fat One',
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

class SpotlightPainter extends CustomPainter {
  final Offset offset;
  final Size size;
  final double spotlightRadius;

  SpotlightPainter({
    required this.offset,
    required this.size,
    this.spotlightRadius = 20,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Draw the dark overlay that covers the entire screen
    final darkPaint = Paint()..color = Colors.transparent;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      darkPaint,
    );

    // Create the spotlight area - this is the box that will be highlighted
    // The spotlight includes the entire box content plus padding for the border
    final spotlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - 8,
        offset.dy - 8,
        size.width + 8,
        size.height + 8,
      ),
      Radius.circular(spotlightRadius),
    );

    // Create a path for the entire screen
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Create a path for the spotlight area
    final spotlightPath = Path()..addRRect(spotlightRect);

    // Combine paths: subtract the spotlight from the full screen to create the dark overlay with a cutout
    final darkOverlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      spotlightPath,
    );

    // Draw the dark overlay with the spotlight cutout
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.75);
    canvas.drawPath(darkOverlayPath, overlayPaint);

    // Draw the yellow border around the spotlight
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD400)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(spotlightRect, borderPaint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.size != size ||
        oldDelegate.spotlightRadius != spotlightRadius;
  }
}
