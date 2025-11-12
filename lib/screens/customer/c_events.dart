import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/pixelarticons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class CustomerEvents extends StatefulWidget {
  final String? userId;
  final bool isBrowseMode;

  const CustomerEvents({super.key, this.userId, this.isBrowseMode = false});

  @override
  State<CustomerEvents> createState() => _CustomerEventsState();
}

class _CustomerEventsState extends State<CustomerEvents> {
  Future<List<Event>> upcomingEvents = Future.value([]);
  Set<String> likedEventIds = {}; // Track liked events

  @override
  void initState() {
    super.initState();
    final service = EventService();
    upcomingEvents = service.fetchEvents(type: "upcoming");
  }

  void _toggleLike(String eventId) {
    setState(() {
      if (likedEventIds.contains(eventId)) {
        likedEventIds.remove(eventId);
      } else {
        likedEventIds.add(eventId);
      }
    });
  }

  Widget _buildEventRow(Event event) {
    final isLiked = likedEventIds.contains(event.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerEventDetailsPage(event: event),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Event name + Like button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Iconify(
                      Carbon.event,
                      color: Color(0xFF276700),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.name.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF276700),
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _toggleLike(event.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF74CC00),
                      width: 2,
                    ),
                    color: isLiked ? const Color(0xFF74CC00) : Colors.white,
                  ),
                  child: isLiked
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: When + Time
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      "WHEN: ",
                      style: TextStyle(
                        fontFamily: "Starla",
                        fontSize: 12,
                        color: Color(0xFF276700),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "${event.scheduleStartDate} - ${event.scheduleEndDate}",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Color(0xFF569109),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${event.scheduleStartTime} - ${event.scheduleEndTime}",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 10,
                      color: Color(0xFF276700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Iconify(
                    Pixelarticons.clock,
                    color: Color(0xFF74CC00),
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Row 3: Where
          Row(
            children: [
              const Text(
                "WHERE: ",
                style: TextStyle(
                  fontFamily: "Starla",
                  fontSize: 12,
                  color: Color(0xFF276700),
                ),
              ),
              Expanded(
                child: Text(
                  event.venue ?? "-",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xFF569109),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(height: 1, color: const Color(0xFF276700)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEventsContent() {
    return FutureBuilder<List<Event>>(
      future: upcomingEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: const Color(0xFFDD602D),
              size: 50,
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Error loading events:\n${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No upcoming events available")),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upcoming Events",
                  style: TextStyle(
                    color: Color(0xFF276700),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Note: Tap events for more information!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: const Color(
                      0xFF569109,
                    ).withAlpha((0.9 * 255).toInt()),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFF276700)),
                const SizedBox(height: 12),
              ],
            ),
            ...snapshot.data!.map((event) => _buildEventRow(event)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.7),
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const Text(
                    "Upcoming Events",
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
            image: AssetImage("lib/assets/images/c-events-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildEventsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerEventDetailsPage extends StatelessWidget {
  final Event event;

  const CustomerEventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF569109)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.event_rounded, size: 28, color: Color(0xFF569109)),
            SizedBox(width: 8),
            Text(
              "Event Details",
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/event-details-pop-ups-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name
              Row(
                children: [
                  const Iconify(
                    Carbon.event,
                    color: Color(0xFF276700),
                    size: 35,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.name.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF276700),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // WHERE
              Row(
                children: [
                  const Text(
                    "WHERE: ",
                    style: TextStyle(
                      fontFamily: "Starla",
                      fontSize: 15,
                      color: Color(0xFF276700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      event.venue ?? "-",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Color(0xFF569109),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // WHEN
              Row(
                children: [
                  const Text(
                    "WHEN: ",
                    style: TextStyle(
                      fontFamily: "Starla",
                      fontSize: 15,
                      color: Color(0xFF276700),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${event.scheduleStartDate} - ${event.scheduleEndDate}",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Color(0xFF569109),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // TIME with clock icon
              Row(
                children: [
                  const Iconify(
                    Pixelarticons.clock,
                    color: Color(0xFF74CC00),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${event.scheduleStartTime} - ${event.scheduleEndTime}",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                        color: Color(0xFF276700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                "EVENT DESCRIPTION",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF276700),
                ),
              ),
              Text(
                event.description ?? "-",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13,
                  color: Color(0xFF276700),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
