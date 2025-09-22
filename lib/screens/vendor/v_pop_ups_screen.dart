import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/pixelarticons.dart';
import '../../models/vendor.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class VendorPopUps extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorPopUps({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  State<VendorPopUps> createState() => _VendorPopUpsState();
}

class _VendorPopUpsState extends State<VendorPopUps>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ["Upcoming", "Joined", "Past"];

  Future<List<Event>> upcomingEvents = Future.value([]);
  Future<List<Event>> joinedEvents = Future.value([]);
  Future<List<Event>> pastEvents = Future.value([]);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    final service = EventService();
    upcomingEvents = service.fetchEvents(type: "upcoming");
    joinedEvents = service.fetchEvents(
      type: "joined",
      vendorId: widget.vendorId,
    );
    pastEvents = service.fetchEvents(type: "past");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEventRow(Event event) {
    final slotsLeft = (event.maxSlots ?? 0) - event.slotsTaken;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
      },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Event name + Slots
          Row(
            children: [
              // Icon + Name
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

              // Slots (right aligned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0FABC),
                  border: Border.all(color: Color(0xFF74CC00)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slotsLeft == event.maxSlots
                      ? "${event.maxSlots} SLOTS ONLY"
                      : "$slotsLeft SLOTS LEFT",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10,
                    color: Color(0xFF276700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: When (date) + Time
          Row(
            children: [
              // Date
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

              // Time (right aligned)
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

          // Row 4: Apply button
          Align(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9E17),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  side: const BorderSide(color: Color(0xFFDD602D)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                minimumSize: Size(0, 0),
              ),
              onPressed: () async {
                final success = await EventService().applyAsVendor(
                  eventId: event.id,
                  vendorId: widget.vendorId,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Applied as merchant successfully!"
                          : "Failed to apply.",
                    ),
                  ),
                );
              },
              child: const Text(
                "Apply as a Merchant!",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          Container(height: 1, color: Color(0xFF276700)), // Divider
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabContent(Future<List<Event>> eventsFuture) {
    return FutureBuilder<List<Event>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              child: Text(
                "Error loading events:\n${snapshot.error.toString()}",
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No events available"));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.length + 1, // +1 for the header
          itemBuilder: (context, index) {
            if (index == 0) {
              // Header section
              return Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      tabs[_tabController.index],
                      style: const TextStyle(
                        color: Color(0xFF276700),
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
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
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Color(0xFF276700)),
                  const SizedBox(height: 12),
                ],
              );
            }
            // Event rows
            return _buildEventRow(snapshot.data![index - 1]);
          },
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF569109),
                      size: 28,
                    ),
                  ),
                  const Icon(
                    Icons.storefront_rounded,
                    size: 28,
                    color: Color(0xFF569109),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Pop Ups",
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
            image: AssetImage("lib/assets/images/pop-ups-bg.png"),
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
                child: Column(
                  children: [
                    // Custom Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDADADB),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Stack(
                        children: [
                          // Animated Indicator
                          AnimatedAlign(
                            alignment: Alignment(
                              -1.0 +
                                  (2.0 / (tabs.length - 1)) *
                                      _tabController.index,
                              0,
                            ),
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width /
                                      tabs.length -
                                  32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tabs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(tabs.length, (index) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _tabController.index = index;
                                    });
                                  },
                                  child: Container(
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      tabs[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: _tabController.index == index
                                            ? Colors.black87
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Content
                    Expanded(
                      child: IndexedStack(
                        index: _tabController.index,
                        children: [
                          _buildTabContent(upcomingEvents),
                          _buildTabContent(joinedEvents),
                          _buildTabContent(pastEvents),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final slotsLeft = (event.maxSlots ?? 0) - event.slotsTaken;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF569109)),
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded, size: 28, color: Color(0xFF569109)),
            SizedBox(width: 8),
            Text(
              "APPLY AS A MERCHANT",
              style: TextStyle(
                fontFamily: 'Starla',
                fontSize: 22,
                color: Color(0xFF569109),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("WHERE: ${event.venue ?? '-'}"),
            Text("WHEN: ${event.scheduleStartDate} - ${event.scheduleEndDate}"),
            Text("TIME: ${event.scheduleStartTime} - ${event.scheduleEndTime}"),
            const SizedBox(height: 12),
            Text("Description: ${event.description ?? '-'}"),
            Text("Requirements: ${event.requirements ?? '-'}"),
            Text("Booth Fee: ₱${event.boothFee ?? 0}"),
            Text("Slots Left: $slotsLeft"),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // call applyAsVendor here
                    },
                    child: const Text(
                      "APPLY AS A MERCHANT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD602D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
