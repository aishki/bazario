import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/heroicons.dart';

class VendorDashboard extends StatelessWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final String? logoUrl;

  const VendorDashboard({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
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
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8685B),
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: logoUrl != null && logoUrl!.isNotEmpty
                            ? NetworkImage(logoUrl!)
                            : const AssetImage("lib/assets/images/logo_img.png")
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
                          style: TextStyle(
                            fontFamily: 'Starla',
                            fontSize: 18,
                            color: Color(0xFFFF390F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          businessName,
                          style: TextStyle(
                            fontFamily: 'Starla',
                            fontSize: 16,
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
                  color: const Color(0xFFF9FFBA), // Yellow
                  borderColor: const Color(0xFFFFD400), // Dark yellow
                  icon: const Iconify(Heroicons.play_circle),
                  label: "My Shop",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('My Shop coming soon')),
                    );
                  },
                ),
                _buildDashboardBox(
                  color: const Color(0xFFD8FEA5), // Green
                  borderColor: const Color(0xFF74CC00), // Dark green
                  icon: const Iconify(Heroicons.play_circle),
                  label: "Pop-ups",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pop-ups coming soon')),
                    );
                  },
                ),
                _buildDashboardBox(
                  color: const Color(0xFFBEDCFF), // Blue
                  borderColor: const Color(0xFF045DC4), // Dark blue
                  icon: const Iconify(Heroicons.play_circle),
                  label: "My Docs",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('My Docs coming soon')),
                    );
                  },
                ),
                _buildDashboardBox(
                  color: const Color(0xFFFFD498), // Orange
                  borderColor: const Color(0xFFFF9E17), // Dark orange
                  icon: const Iconify(Heroicons.play_circle),
                  label: "Notifs",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifs coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBox({
    required Color color,
    required Color borderColor,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
