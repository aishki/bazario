import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';

class CNotificationsScreen extends StatefulWidget {
  final String customerId;

  const CNotificationsScreen({Key? key, required this.customerId})
    : super(key: key);

  @override
  State<CNotificationsScreen> createState() => _CNotificationsScreenState();
}

class _CNotificationsScreenState extends State<CNotificationsScreen> {
  late NotificationService _notificationService;
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationsFuture = _notificationService.getNotifications(
      widget.customerId,
    );
    _notificationService.startNotificationListener(widget.customerId);
  }

  @override
  void dispose() {
    _notificationService.stopNotificationListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E17)),
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
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationCard(notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    Color statusColor = const Color(0xFFFF9E17);
    IconData statusIcon = Icons.hourglass_bottom;
    Widget? statusLabelWidget;

    // Determine status color, icon, and label based on notif.status
    switch (notif.status) {
      case 'paid':
        statusColor = const Color(0xFFFF9E17);
        statusIcon = Icons.error_outline;
        statusLabelWidget = Row(
          children: const [
            Icon(Icons.error_outline, size: 16, color: Color(0xFFFF9E17)),
            SizedBox(width: 4),
            Text(
              "Payment Under Review",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9E17),
              ),
            ),
          ],
        );
        break;
      case 'payment verified':
        statusColor = const Color(0xFF74CC00);
        statusIcon = Icons.check_circle_outline;
        statusLabelWidget = Row(
          children: const [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Color(0xFF74CC00),
            ),
            SizedBox(width: 4),
            Text(
              "Order is being prepared",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF74CC00),
              ),
            ),
          ],
        );
        break;
      case 'to receive':
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.local_shipping_outlined;
        statusLabelWidget = Row(
          children: const [
            Icon(Icons.local_shipping, size: 16, color: Color(0xFFDD602D)),
            SizedBox(width: 4),
            Text(
              "The courier is on the way!",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDD602D),
              ),
            ),
          ],
        );
        break;
      case 'completed':
        statusColor = const Color(0xFF74CC00);
        statusIcon = Icons.check_circle;
        statusLabelWidget = Row(
          children: const [
            Icon(Icons.check_circle, size: 16, color: Color(0xFF569109)),
            SizedBox(width: 4),
            Text(
              "Completed",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF569109),
              ),
            ),
          ],
        );
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF5350);
        statusIcon = Icons.cancel_outlined;
        statusLabelWidget = Row(
          children: const [
            Icon(Icons.cancel, size: 16, color: Color(0xFFFF390F)),
            SizedBox(width: 4),
            Text(
              "Cancelled",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF390F),
              ),
            ),
          ],
        );
        break;
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
                                  color: const Color(0xFFFF9E17),
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
