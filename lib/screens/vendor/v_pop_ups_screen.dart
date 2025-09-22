import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/pixelarticons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

  Map<String, bool> _appliedStatus = {}; // eventId -> applied
  Map<String, bool> _receiptStatus = {}; // eventId -> receipt uploaded

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

    // 🔹 Add listener for tab changes
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          _tabController.indexIsChanging == false) {
        // Joined tab selected
        _refreshJoinedEvents();
      }
    });
  }

  Future<void> _refreshJoinedEvents() async {
    final service = EventService();
    final events = await service.fetchEvents(
      type: "joined",
      vendorId: widget.vendorId,
    );

    if (!mounted) return;

    setState(() {
      joinedEvents = Future.value(events);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEventRow(Event event) {
    return FutureBuilder<String?>(
      future: EventService().getVendorStatus(
        eventId: event.id,
        vendorId: widget.vendorId,
      ),
      builder: (context, snapshot) {
        final vendorStatus = snapshot.data; // "applied", "approved", etc.
        final slotsLeft = (event.maxSlots ?? 0) - event.slotsTaken;

        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EventDetailsPage(event: event, vendorId: widget.vendorId),
              ),
            );

            if (result == true) {
              _refreshJoinedEvents(); // refresh joined events
              setState(() {
                upcomingEvents = EventService().fetchEvents(type: "upcoming");
                pastEvents = EventService().fetchEvents(type: "past");
              });
            }
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Event name + Slots
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
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

              // Row 4: Apply Button + Upload Receipt
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (vendorStatus == null)
                          ? const Color(0xFFFF9E17) // not applied
                          : const Color.fromARGB(
                              145,
                              112,
                              104,
                              101,
                            ), // already applied
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      minimumSize: const Size(120, 0), // fixed width + height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (vendorStatus == null) {
                        final success = await EventService().applyAsVendor(
                          eventId: event.id,
                          vendorId: widget.vendorId,
                        );

                        if (!mounted) return;
                        if (success) {
                          setState(() {
                            _appliedStatus[event.id] = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Applied as merchant successfully!",
                              ),
                            ),
                          );
                          // REFRESH joinedEvents so the tab shows latest
                          if (_tabController.index == 1) {
                            // joined tab
                            await _refreshJoinedEvents();
                          } else {
                            setState(() {
                              _appliedStatus[event.id] = true;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Failed to apply. Please try again.",
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "You already applied for this event! Kindly wait for the admin's approval.",
                            ),
                          ),
                        );
                      }
                    },
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            vendorStatus == null
                                ? "APPLY"
                                : vendorStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),

                  const SizedBox(width: 12), // space between buttons

                  if (vendorStatus == "applied")
                    ElevatedButton(
                      onPressed: () => _openUploadReceiptDialog(event),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        minimumSize: const Size(0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "UPLOAD RECEIPT",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              Container(height: 1, color: Color(0xFF276700)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openUploadReceiptDialog(Event event) {
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDD602D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Image.network(
                                "https://res.cloudinary.com/ddnkxzfii/image/upload/v1758788271/ef67ce5c-e63f-4a91-bed7-1be3fb2b5a5c.png",
                                height: 200,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Amount Due: ₱${event.boothFee}",
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setStateDialog(() => pickedImage = image);
                              }
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: pickedImage == null
                                  ? const Center(child: Text("Upload Receipt"))
                                  : Image.file(File(pickedImage!.path)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (pickedImage != null) {
                          final success = await EventService().uploadReceipt(
                            eventId: event.id,
                            vendorId: widget.vendorId,
                            receiptFile: File(pickedImage!.path),
                          );
                          if (success && mounted) {
                            setState(() {
                              _receiptStatus[event.id] = true;
                            });
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Receipt uploaded successfully"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Submit Receipt"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabContent(Future<List<Event>> eventsFuture, {Key? key}) {
    return FutureBuilder<List<Event>>(
      key: key,
      future: eventsFuture,
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
            child: Center(child: Text("No events available")),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_tabController.index < tabs.length)
                      ? tabs[_tabController.index]
                      : "",
                  style: const TextStyle(
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
                Container(height: 1, color: Color(0xFF276700)),
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
                                  16,
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
                                            ? const Color(0xFF276700)
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
                    Expanded(
                      child: IndexedStack(
                        index: _tabController.index,
                        children: [
                          _buildTabContent(upcomingEvents),
                          _buildTabContent(
                            joinedEvents,
                            key: ValueKey(joinedEvents),
                          ), // 🔹 add Key
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

class EventDetailsPage extends StatefulWidget {
  final Event event;
  final String vendorId;

  const EventDetailsPage({
    super.key,
    required this.event,
    required this.vendorId,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late bool _applied;
  bool _receiptUploaded = false;
  String? _vendorStatus; // "applied", "approved", "denied", or null
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Initialize from event data
    _applied = widget.event.hasVendorApplied;
    _receiptUploaded = widget.event.hasUploadedReceipt;
    _fetchVendorStatus();
  }

  Future<void> _fetchVendorStatus() async {
    final status = await EventService().getVendorStatus(
      eventId: widget.event.id,
      vendorId: widget.vendorId,
    );
    if (mounted) {
      setState(() {
        _vendorStatus = status; // "applied", "approved", "denied", or null
        _loading = false;
      });
    }
  }

  void _openUploadReceiptDialog() {
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDD602D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // QR + Fee
                        Expanded(
                          child: Column(
                            children: [
                              Image.network(
                                "https://res.cloudinary.com/ddnkxzfii/image/upload/v1758788271/ef67ce5c-e63f-4a91-bed7-1be3fb2b5a5c.png",
                                height: 200,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Amount Due: ₱${widget.event.boothFee}",
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Upload
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setStateDialog(() => pickedImage = image);
                              }
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: pickedImage == null
                                  ? const Center(child: Text("Upload Receipt"))
                                  : Image.file(File(pickedImage!.path)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (pickedImage != null) {
                          final success = await EventService().uploadReceipt(
                            eventId: widget.event.id,
                            vendorId: widget.vendorId,
                            receiptFile: File(pickedImage!.path),
                          );
                          if (success) {
                            if (!mounted) return;
                            setState(() => _receiptUploaded = true);
                            Navigator.pop(dialogContext); // ✅ use dialogContext
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Receipt uploaded successfully"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Submit Receipt"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotsLeft = (widget.event.maxSlots ?? 0) - widget.event.slotsTaken;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF569109)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context, true), // ✅ return true like cancel
        ),
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
              widget.event.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("WHERE: ${widget.event.venue ?? '-'}"),
            Text(
              "WHEN: ${widget.event.scheduleStartDate} - ${widget.event.scheduleEndDate}",
            ),
            Text(
              "TIME: ${widget.event.scheduleStartTime} - ${widget.event.scheduleEndTime}",
            ),
            const SizedBox(height: 12),
            Text("Description: ${widget.event.description ?? '-'}"),
            Text("Requirements: ${widget.event.requirements ?? '-'}"),
            Text("Booth Fee: ₱${widget.event.boothFee}"),
            const SizedBox(height: 8),
            if (_vendorStatus == "applied") ...[
              ElevatedButton(
                onPressed: _openUploadReceiptDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD400),
                ),
                child: const Text("UPLOAD RECEIPT"),
              ),
              const SizedBox(height: 8),
              Text(
                _receiptUploaded
                    ? "We have received your application and receipt submission! Kindly wait as we verify your payment."
                    : "Please upload your receipt of the booth payment fee to progress with your application for the event.",
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Poppins",
                  color: Colors.black54,
                ),
              ),
            ],
            Text("Slots Left: $slotsLeft"),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _loading
                      ? Center(
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Color(0xFFDD602D),
                            size: 35,
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD400),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: (_vendorStatus == null)
                              ? () async {
                                  final success = await EventService()
                                      .applyAsVendor(
                                        eventId: widget.event.id,
                                        vendorId: widget.vendorId,
                                      );
                                  if (success) {
                                    setState(() => _vendorStatus = "applied");
                                  }
                                }
                              : null,
                          child: Text((_vendorStatus ?? "APPLY").toUpperCase()),
                        ),
                ),
                if (_applied) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _openUploadReceiptDialog,
                    child: const Text("UPLOAD RECEIPT"),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD602D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, true),
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
