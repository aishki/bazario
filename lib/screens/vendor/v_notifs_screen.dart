import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'dart:ui';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../models/vendor.dart';

class VendorNotificationScreen extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorNotificationScreen({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  late NotificationService _notificationService;
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationsFuture = _notificationService.getNotifications(widget.userId);
    _notificationService.startNotificationListener(widget.userId);
  }

  @override
  void dispose() {
    _notificationService.stopNotificationListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.1),
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF569109),
                      size: 28,
                    ),
                  ),
                  const Iconify(
                    "streamline-plump:announcement-megaphone",
                    size: 24,
                    color: Color(0xFF569109),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontFamily: 'Starla',
                      fontSize: 22,
                      color: Color(0xFF569109),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(height: 2, color: const Color(0xFF74CC00)),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/notifs-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<AppNotification>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF569109)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 115,
                bottom: 16,
              ),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(notif);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    Color statusColor = const Color(0xFF569109);
    IconData statusIcon = Icons.notifications_active;
    Widget? statusLabelWidget;

    // Determine icon and label based on notification type
    switch (notif.type) {
      case 'order_update':
        statusColor = const Color(0xFFFF9E17);
        statusIcon = Icons.shopping_cart_outlined;
        statusLabelWidget = Row(
          children: const [
            Icon(
              Icons.shopping_cart_outlined,
              size: 16,
              color: Color(0xFFFF9E17),
            ),
            SizedBox(width: 4),
            Text(
              "Order Update",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9E17),
              ),
            ),
          ],
        );
        break;
      case 'verification':
        statusColor = const Color(0xFF74CC00);
        statusIcon = Icons.verified_user_outlined;
        statusLabelWidget = Row(
          children: const [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: Color(0xFF74CC00),
            ),
            SizedBox(width: 4),
            Text(
              "Verification",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF74CC00),
              ),
            ),
          ],
        );
        break;
      case 'event_reminder':
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.event_outlined;
        statusLabelWidget = Row(
          children: const [
            Icon(Icons.event_outlined, size: 16, color: Color(0xFF2196F3)),
            SizedBox(width: 4),
            Text(
              "Event Reminder",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        );
        break;
      default:
        statusColor = const Color(0xFF569109);
        statusIcon = Icons.notifications_active;
        statusLabelWidget = Row(
          children: const [
            Icon(
              Icons.notifications_active,
              size: 16,
              color: Color(0xFF569109),
            ),
            SizedBox(width: 4),
            Text(
              "Notification",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF569109),
              ),
            ),
          ],
        );
    }

    bool isLongMessage = notif.message.length > 60;
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setStateCard) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notif.read ? 0 : 2,
        color: notif.read ? Colors.white : const Color(0xFFFFF9E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini Header with icon + label
              if (statusLabelWidget != null) ...[
                statusLabelWidget,
                const SizedBox(height: 6),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: isExpanded ? null : 1,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Time + Expand Icon Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(notif.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (isLongMessage)
                              GestureDetector(
                                onTap: () async {
                                  if (!notif.read) {
                                    await _notificationService.markAsRead(
                                      notif.id,
                                    );
                                    setState(() {
                                      notif.read = true;
                                    });
                                  }
                                  setStateCard(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: const Color(0xFF569109),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
