import 'package:flutter/material.dart';

class VendorAnnouncementsScreen extends StatelessWidget {
  const VendorAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9E17), Color(0xFFFFD400)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Starla',
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Notifications List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildNotificationItem(
                          title: 'New Order Received',
                          message:
                              'You have a new order from customer John Doe',
                          time: '2 minutes ago',
                          isRead: false,
                        ),
                        _buildNotificationItem(
                          title: 'Product Review',
                          message:
                              'Your product "Fresh Mangoes" received a 5-star review',
                          time: '1 hour ago',
                          isRead: true,
                        ),
                        _buildNotificationItem(
                          title: 'Payment Received',
                          message:
                              'Payment of ₱500 has been received for order #12345',
                          time: '3 hours ago',
                          isRead: true,
                        ),
                        _buildNotificationItem(
                          title: 'Profile Update',
                          message:
                              'Your vendor profile has been successfully updated',
                          time: '1 day ago',
                          isRead: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : const Color(0xFFFF9E17),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isRead ? Colors.grey[400] : const Color(0xFFFF9E17),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.grey[600] : const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRead ? Colors.grey[500] : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          // Unread indicator
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9E17),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
