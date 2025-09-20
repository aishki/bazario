import 'dart:convert';
import 'package:intl/intl.dart';

class Event {
  final String id;
  final String createdBy; // user UUID
  final String name;
  final String? description;
  final String? venue;
  final String? posterUrl;
  final DateTime scheduleStart;
  final DateTime? scheduleEnd;
  final DateTime createdAt;
  final String? requirements;
  final double boothFee;
  final int? maxSlots;
  final int slotsTaken;

  Event({
    required this.id,
    required this.createdBy,
    required this.name,
    this.description,
    this.venue,
    this.posterUrl,
    required this.scheduleStart,
    this.scheduleEnd,
    required this.createdAt,
    this.requirements,
    this.boothFee = 0.0,
    this.maxSlots,
    this.slotsTaken = 0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      createdBy: json['created_by'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      venue: json['venue'],
      posterUrl: json['poster_url'],
      scheduleStart: DateTime.parse(json['schedule_start']),
      scheduleEnd: json['schedule_end'] != null
          ? DateTime.parse(json['schedule_end'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      requirements: json['requirements'],
      boothFee: (json['booth_fee'] != null)
          ? double.tryParse(json['booth_fee'].toString()) ?? 0.0
          : 0.0,

      maxSlots: json['max_slots'],
      slotsTaken: json['slots_taken'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'name': name,
      'description': description,
      'venue': venue,
      'poster_url': posterUrl,
      'schedule_start': scheduleStart.toIso8601String(),
      'schedule_end': scheduleEnd?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'requirements': requirements,
      'booth_fee': boothFee,
      'max_slots': maxSlots,
      'slots_taken': slotsTaken,
    };
  }

  static List<Event> listFromJson(List<dynamic> list) {
    return list.map((e) => Event.fromJson(e)).toList();
  }

  // Convenience getters
  String get scheduleStartDate => DateFormat('MMM d,').format(scheduleStart);
  String get scheduleEndDate => scheduleEnd != null
      ? DateFormat('MMM d, yyyy').format(scheduleEnd!)
      : '-';

  String get scheduleStartTime => DateFormat('h:mm a').format(scheduleStart);
  String get scheduleEndTime =>
      scheduleEnd != null ? DateFormat('h:mm a').format(scheduleEnd!) : '-';

  @override
  String toString() => jsonEncode(toJson());
}
