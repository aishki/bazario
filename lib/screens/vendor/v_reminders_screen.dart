import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/event_reminder_service.dart';
import '../../services/auth_service.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../models/event_reminder.dart';

class VendorRemindersScreen extends StatefulWidget {
  const VendorRemindersScreen({super.key});

  @override
  State<VendorRemindersScreen> createState() => _VendorRemindersScreenState();
}

class _VendorRemindersScreenState extends State<VendorRemindersScreen> {
  final EventReminderService _reminderService = EventReminderService();
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  String? _vendorId;
  List<EventReminder> _reminders = [];
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = await _authService.getUserSession();
    if (session != null && session['vendor_id'] != null) {
      _vendorId = session['vendor_id'];
      await _loadReminders();
      await _loadEvents();
    }
    setState(() => _loading = false);
  }

  Future<void> _loadReminders() async {
    if (_vendorId != null) {
      final reminders = await _reminderService.getVendorReminders(_vendorId!);
      debugPrint('[VendorReminders] Loaded ${reminders.length} reminders');
      for (var r in reminders) {
        debugPrint(
          '[VendorReminders] Reminder: ${r.eventName} at ${r.reminderDatetime}',
        );
      }
      setState(() => _reminders = reminders);
    }
  }

  Future<void> _loadEvents() async {
    if (_vendorId != null) {
      final events = await _eventService.fetchEvents(
        type: "joined",
        vendorId: _vendorId!,
      );
      setState(() => _events = events);
    }
  }

  void _showAddReminderDialog() {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    Event? selectedEvent;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFDD602D), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '➕ ADD REMINDER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD602D),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),

                // Event Selector
                const Text(
                  'Event',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD602D),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDD602D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<Event>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Select an event'),
                    value: selectedEvent,
                    items: _events.map((event) {
                      return DropdownMenuItem(
                        value: event,
                        child: Text(event.name),
                      );
                    }).toList(),
                    onChanged: (Event? event) {
                      setDialogState(() => selectedEvent = event);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD602D),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDD602D)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy').format(selectedDate!)
                          : 'Select date',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFDD602D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Picker
                const Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDD602D),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDD602D)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Select time',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFDD602D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFDD602D)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFDD602D)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedEvent == null ||
                            selectedDate == null ||
                            selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        final reminderDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        final success = await _reminderService.createReminder(
                          vendorId: _vendorId!,
                          eventId: selectedEvent!.id,
                          reminderDatetime: reminderDateTime,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          if (success) {
                            await _loadReminders();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder added successfully!'),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD602D),
                      ),
                      child: const Text(
                        'Add Reminder',
                        style: TextStyle(color: Colors.white),
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

  void _deleteReminder(String reminderId) async {
    final success = await _reminderService.deleteReminder(reminderId);
    if (success) {
      await _loadReminders();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
      }
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
                image: AssetImage('lib/assets/images/notifs-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFDD602D),
                          size: 24,
                        ),
                      ),
                      const Text(
                        'Event Reminders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD602D),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddReminderDialog,
                        child: const Icon(
                          Icons.add_circle,
                          color: Color(0xFFDD602D),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Reminders List
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFDD602D),
                          ),
                        )
                      : _reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'No reminders yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFDD602D),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    color: const Color(0xFFDD602D),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reminder.displayLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                            color: Color(0xFFDD602D),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat(
                                            'MMM d, yyyy h:mm a',
                                          ).format(reminder.reminderDatetime),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'In ${reminder.timeUntilReminder}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _deleteReminder(reminder.id),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFFC55153),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
