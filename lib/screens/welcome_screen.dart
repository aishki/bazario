import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'customer/c_dashboard.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/welcome-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFF74CC00), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upper section with logo and description
                Column(
                  children: [
                    Image.asset(
                      'lib/assets/images/bazario-logo.png',
                      width: 250,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bazario brings your neighborhood marketplace to your fingertips. Log in to explore shops, get notified on updates, and support local businesses.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF559109),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Green divider line
                Container(
                  height: 2,
                  width: double.infinity,
                  color: const Color(0xFF74CC00),
                ),
                const SizedBox(height: 24),
                // Lower section with two action rectangles
                Column(
                  children: [
                    // Login rectangle
                    _buildActionRectangle(
                      context: context,
                      leftText: 'Already part of the family?\nLog in here!',
                      buttonText: 'Log In',
                      borderColor: const Color(0xFF74CC00), // green border
                      bgImage: 'lib/assets/images/welcome-button1-bg.png',
                      iconImage: 'lib/assets/icons/login.png',
                      textColor: const Color(0xFF569109),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Explore rectangle
                    _buildActionRectangle(
                      context: context,
                      leftText:
                          'Check out what our NeighborGoods have to offer!',
                      buttonText: 'Explore',
                      borderColor: const Color(0xFFFF9800), // orange border
                      bgImage: 'lib/assets/images/welcome-button2-bg.png',
                      iconImage: 'lib/assets/icons/explore.png',
                      textColor: const Color(0xFFFF9E17),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerDashboard(isBrowseMode: true),
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
      ),
    );
  }

  Widget _buildActionRectangle({
    required BuildContext context,
    required String leftText,
    required String buttonText,
    required VoidCallback onPressed,
    required Color borderColor,
    required String bgImage,
    required String iconImage,
    required Color textColor,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          // Left side with text
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Center(
                child: Text(
                  leftText,
                  style: TextStyle(
                    fontFamily: 'Starla',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Vertical divider (full height)
          Container(width: 1, color: borderColor),
          // Right side with image and button
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconImage,
                    height: 55,
                    width: 55,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 48,
                    height: 20, // smaller button
                    child: OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: borderColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontFamily: 'Bagel Fat One',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
