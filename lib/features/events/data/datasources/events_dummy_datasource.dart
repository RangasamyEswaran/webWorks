import '../../../../core/error/exceptions.dart';
import 'events_remote_datasource.dart';
import '../models/event_dto.dart';

class EventsDummyDataSourceImpl implements EventsRemoteDataSource {
  final List<EventDto> _dummyEvents = [
    EventDto(
      id: '1',
      title: 'Flutter Forward 2026',
      description:
          'Join us for the biggest Flutter event of the year! Learn about the latest updates, connect with the community, and build amazing apps.',
      startDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      endDate: DateTime.now()
          .add(const Duration(days: 5, hours: 8))
          .toIso8601String(),
      location: 'Moscone Center, San Francisco, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1625225230517-7426c1be750c?auto=format&fit=crop&q=80&w=2070',
      category: 'Conference',
      maxAttendees: 500,
      currentAttendees: 342,
      isRegistered: false,
      status: 'upcoming',
      latitude: 37.784172,
      longitude: -122.401558,
    ),
    EventDto(
      id: '2',
      title: 'SF Tech Meetup',
      description:
          'Monthly gathering for tech enthusiasts in San Francisco. Networking, talks, and pizza!',
      startDate: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      endDate: DateTime.now()
          .add(const Duration(days: 2, hours: 3))
          .toIso8601String(),
      location: 'Salesforce Tower, San Francisco, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1544531586-fde5298cdd40?auto=format&fit=crop&q=80&w=2070',
      category: 'Meetup',
      maxAttendees: 150,
      currentAttendees: 120,
      isRegistered: true,
      status: 'upcoming',
      latitude: 37.7897,
      longitude: -122.3972,
    ),
    EventDto(
      id: '3',
      title: 'Design Systems Workshop',
      description:
          'Learn how to build and maintain scalable design systems using Figma and Flutter.',
      startDate: DateTime.now().add(const Duration(days: 10)).toIso8601String(),
      endDate: DateTime.now()
          .add(const Duration(days: 10, hours: 6))
          .toIso8601String(),
      location: 'Mission District, San Francisco, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1531403009284-440f8804f1e9?auto=format&fit=crop&q=80&w=2070',
      category: 'Workshop',
      maxAttendees: 40,
      currentAttendees: 25,
      isRegistered: false,
      status: 'upcoming',
      latitude: 37.7599,
      longitude: -122.4144,
    ),
    EventDto(
      id: '4',
      title: 'AI in San Francisco',
      description:
          'Exploring the impact of Generative AI on the local tech ecosystem. Panel discussion with industry leaders.',
      startDate: DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      endDate: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      location: 'Union Square, San Francisco, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1559223607-a43c990ed19d?auto=format&fit=crop&q=80&w=2070',
      category: 'Discussion',
      maxAttendees: 300,
      currentAttendees: 280,
      isRegistered: false,
      status: 'ongoing',
      latitude: 37.7879,
      longitude: -122.4075,
    ),
    EventDto(
      id: '5',
      title: 'SF Hackathon 2026',
      description:
          '48 hours of building, innovative solutions for the future of urban living. Prizes for top teams!',
      startDate: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      endDate: DateTime.now().add(const Duration(days: 17)).toIso8601String(),
      location: 'Embarcadero, San Francisco, CA',
      imageUrl:
          'https://images.unsplash.com/photo-1587620962725-abab7fe55159?auto=format&fit=crop&q=80&w=2070',
      category: 'Hackathon',
      maxAttendees: 100,
      currentAttendees: 65,
      isRegistered: false,
      status: 'upcoming',
      latitude: 37.7955,
      longitude: -122.3937,
    ),
  ];
  List<EventDto> get dummyEvents => _dummyEvents;

  @override
  Future<List<EventDto>> getEvents({
    required int page,
    required int pageSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyEvents;
  }

  @override
  Future<EventDto> getEventDetails(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _dummyEvents.firstWhere((e) => e.id == eventId);
    } catch (e) {
      throw ServerException(message: 'Event not found', statusCode: 404);
    }
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final index = _dummyEvents.indexWhere((e) => e.id == eventId);
      if (index == -1) {
        throw ServerException(message: 'Event not found', statusCode: 404);
      }

      final event = _dummyEvents[index];
      if (event.isRegistered == true) {
        throw ServerException(message: 'Already registered', statusCode: 400);
      }

      if (event.maxAttendees != null &&
          event.currentAttendees != null &&
          event.currentAttendees! >= event.maxAttendees!) {
        throw ServerException(message: 'Event is full', statusCode: 400);
      }

      final updatedEvent = EventDto(
        id: event.id,
        title: event.title,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        imageUrl: event.imageUrl,
        category: event.category,
        maxAttendees: event.maxAttendees,
        currentAttendees: (event.currentAttendees ?? 0) + 1,
        isRegistered: true,
        status: event.status,
        createdAt: event.createdAt,
      );

      _dummyEvents[index] = updatedEvent;
      return updatedEvent;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Registration failed', statusCode: 500);
    }
  }

  @override
  Future<EventDto> unregisterFromEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final index = _dummyEvents.indexWhere((e) => e.id == eventId);
      if (index == -1) {
        throw ServerException(message: 'Event not found', statusCode: 404);
      }

      final event = _dummyEvents[index];
      if (event.isRegistered != true) {
        throw ServerException(message: 'Not registered', statusCode: 400);
      }

      final updatedEvent = EventDto(
        id: event.id,
        title: event.title,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        imageUrl: event.imageUrl,
        category: event.category,
        maxAttendees: event.maxAttendees,
        currentAttendees: (event.currentAttendees ?? 1) - 1,
        isRegistered: false,
        status: event.status,
        createdAt: event.createdAt,
      );

      _dummyEvents[index] = updatedEvent;
      return updatedEvent;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unregistration failed', statusCode: 500);
    }
  }

  @override
  Future<List<EventDto>> getRegisteredEvents() async {
    return _dummyEvents.where((e) => e.isRegistered == true).toList();
  }
}
