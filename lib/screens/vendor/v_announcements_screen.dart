import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement.dart';
import '../../services/auth_service.dart';
import 'v_reminders_screen.dart';

class VendorAnnouncementsScreen extends StatefulWidget {
  const VendorAnnouncementsScreen({super.key});

  @override
  State<VendorAnnouncementsScreen> createState() =>
      _VendorAnnouncementsScreenState();
}

class _VendorAnnouncementsScreenState extends State<VendorAnnouncementsScreen> {
  Future<List<Announcement>>? _announcementsFuture;
  final AnnouncementService _announcementService = AnnouncementService();
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorAnnouncements();
  }

  Future<void> _loadVendorAnnouncements() async {
    final session = await AuthService().getUserSession();
    if (session != null && session['vendor_id'] != null) {
      _vendorId = session['vendor_id'];
      setState(() {
        _announcementsFuture = _announcementService.getVendorAnnouncements(
          _vendorId!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/notifs-bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    "lib/assets/images/announcement-check-this-out.png",
                    height: 90, // 🔹 Smaller header image
                    fit: BoxFit.contain,
                  ),
                ),

                // Announcements (Top Section)
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: FutureBuilder<List<Announcement>>(
                          future: _announcementsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF9E17),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            final announcements = snapshot.data ?? [];
                            if (announcements.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No announcements yet",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: announcements.length,
                              itemBuilder: (context, index) =>
                                  _buildAnnouncementItem(announcements[index]),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // // 🔴 Divider Line
                // Container(
                //   height: 2,
                //   width: double.infinity,
                //   margin: const EdgeInsets.symmetric(horizontal: 20),
                //   color: const Color(0xFFC55153),
                // ),
                const SizedBox(height: 10),

                // Reminders (Bottom Section)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDD602D),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Event Reminders\nManage reminders for events you joined.",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFDD602D),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VendorRemindersScreen(),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.notifications_active,
                              color: Color(0xFFDD602D),
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Announcement ann) {
    return GestureDetector(
      onTap: () {
        _showAnnouncementDialog(ann, () {
          setState(() {
            // Trigger parent rebuild so likes reflect in list
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: Color(0xFFDD602D)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ann.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ann.message.length > 80
                        ? "${ann.message.substring(0, 80)}..."
                        : ann.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Color(0xFFFF9E17),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ann.likes.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDialog(Announcement ann, VoidCallback onUpdate) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFC55153), width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: StatefulBuilder(
            builder: (context, dialogSetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ann.title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: "Starla",
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFFFF390F),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  ann.message,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 15,
                    color: Color(0xFFDD602D),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "POSTED ${_formatTime(ann.createdAt)}  |  by ${ann.adminName}",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        dialogSetState(() {
                          ann.isLiked = !ann.isLiked;
                          ann.likes += ann.isLiked ? 1 : -1;
                        });

                        if (_vendorId != null) {
                          final success = await _announcementService
                              .likeAnnouncement(
                                ann.id,
                                _vendorId!,
                                ann.isLiked,
                              );
                          if (!success) {
                            dialogSetState(() {
                              ann.isLiked = !ann.isLiked;
                              ann.likes += ann.isLiked ? 1 : -1;
                            });
                          } else {
                            // Update parent widget
                            onUpdate();
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            ann.isLiked
                                ? "Acknowledged!"
                                : "Click to Acknowledge!",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDD602D),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            ann.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFFF9E17),
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
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
