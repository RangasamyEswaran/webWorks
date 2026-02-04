import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? category;
  final int? maxAttendees;
  final int? currentAttendees;
  final bool isRegistered;
  final List<String> attendeeEmails;
  final String status;
  final DateTime? createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.category,
    this.maxAttendees,
    this.currentAttendees,
    this.isRegistered = false,
    this.attendeeEmails = const [],
    this.status = 'upcoming',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    location,
    latitude,
    longitude,
    imageUrl,
    category,
    maxAttendees,
    currentAttendees,
    isRegistered,
    attendeeEmails,
    status,
    createdAt,
  ];

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? category,
    int? maxAttendees,
    int? currentAttendees,
    bool? isRegistered,
    List<String>? attendeeEmails,
    String? status,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      isRegistered: isRegistered ?? this.isRegistered,
      attendeeEmails: attendeeEmails ?? this.attendeeEmails,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isFull =>
      maxAttendees != null &&
      currentAttendees != null &&
      currentAttendees! >= maxAttendees!;
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => endDate != null && DateTime.now().isAfter(endDate!);
}
