import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';

@JsonSerializable()
class EventDto {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String location;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? category;
  @JsonKey(name: 'max_attendees')
  final int? maxAttendees;
  @JsonKey(name: 'current_attendees')
  final int? currentAttendees;
  @JsonKey(name: 'is_registered')
  final bool? isRegistered;
  final String? status;
  @JsonKey(name: 'attendee_emails')
  final List<String>? attendeeEmails;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  EventDto({
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
    this.isRegistered,
    this.status,
    this.attendeeEmails,
    this.createdAt,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      maxAttendees: json['max_attendees'] as int?,
      currentAttendees: json['current_attendees'] as int?,
      isRegistered: json['is_registered'] as bool? ?? false,
      status: json['status'] as String?,
      attendeeEmails: (json['attendee_emails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'start_date': startDate,
    'end_date': endDate,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'image_url': imageUrl,
    'category': category,
    'max_attendees': maxAttendees,
    'current_attendees': currentAttendees,
    'is_registered': isRegistered,
    'status': status,
    'attendee_emails': attendeeEmails,
    'created_at': createdAt,
  };

  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      category: category,
      maxAttendees: maxAttendees,
      currentAttendees: currentAttendees,
      isRegistered: isRegistered ?? false,
      attendeeEmails: attendeeEmails ?? const [],
      status: status ?? 'upcoming',
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  factory EventDto.fromEntity(Event event) {
    return EventDto(
      id: event.id,
      title: event.title,
      description: event.description,
      startDate: event.startDate.toIso8601String(),
      endDate: event.endDate?.toIso8601String(),
      location: event.location,
      latitude: event.latitude,
      longitude: event.longitude,
      imageUrl: event.imageUrl,
      category: event.category,
      maxAttendees: event.maxAttendees,
      currentAttendees: event.currentAttendees,
      isRegistered: event.isRegistered,
      status: event.status,
      attendeeEmails: event.attendeeEmails,
      createdAt: event.createdAt?.toIso8601String(),
    );
  }
}
