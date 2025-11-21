import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';

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

    if (notif.status == 'paid') {
      statusColor = const Color(0xFFFF9E17);
      statusIcon = Icons.error_outline;
    } else if (notif.status == 'payment verified') {
      statusColor = const Color(0xFF74CC00);
      statusIcon = Icons.check_circle_outline;
    } else if (notif.status == 'on the way') {
      statusColor = const Color(0xFF2196F3);
      statusIcon = Icons.local_shipping_outlined;
    } else if (notif.status == 'completed') {
      statusColor = const Color(0xFF74CC00);
      statusIcon = Icons.check_circle;
    } else if (notif.status == 'cancelled') {
      statusColor = const Color(0xFFEF5350);
      statusIcon = Icons.cancel_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notif.read ? 0 : 2,
      color: notif.read ? Colors.white : const Color(0xFFFFF9E6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (!notif.read) {
            _notificationService.markAsRead(notif.id).then((_) {
              setState(() {
                _notificationsFuture = _notificationService.getNotifications(
                  widget.customerId,
                );
              });
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.message,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notif.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9E17),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notif.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
