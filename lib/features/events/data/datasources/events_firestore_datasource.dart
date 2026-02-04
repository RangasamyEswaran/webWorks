import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/event_dto.dart';
import 'events_remote_datasource.dart';

class EventsFirestoreDataSourceImpl implements EventsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  EventsFirestoreDataSourceImpl({required this.firestore, FirebaseAuth? auth})
    : auth = auth ?? FirebaseAuth.instance;

  String? get _currentUserEmail => auth.currentUser?.email;

  @override
  Future<List<EventDto>> getEvents({
    required int page,
    required int pageSize,
  }) async {
    try {
      final snapshot = await firestore
          .collection('events')
          .orderBy('start_date')
          .limit(pageSize * page)
          .get();

      final userEmail = _currentUserEmail;

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final List<String> attendeeEmails =
            ((data['attendee_emails'] ?? data['attendeeEmails'])
                    as List<dynamic>?)
                ?.map((e) => e.toString().trim())
                .toList() ??
            [];
        final isRegistered =
            userEmail != null && attendeeEmails.contains(userEmail.trim());

        return EventDto.fromJson({
          ...data,
          'id': doc.id,
          'is_registered': isRegistered,
        });
      }).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> getEventDetails(String eventId) async {
    try {
      final doc = await firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final userEmail = _currentUserEmail;
        final List<String> attendeeEmails =
            ((data['attendee_emails'] ?? data['attendeeEmails'])
                    as List<dynamic>?)
                ?.map((e) => e.toString().trim())
                .toList() ??
            [];
        final isRegistered =
            userEmail != null && attendeeEmails.contains(userEmail.trim());

        return EventDto.fromJson({
          ...data,
          'id': doc.id,
          'is_registered': isRegistered,
        });
      } else {
        throw ServerException(message: 'Event not found', statusCode: 404);
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    try {
      final userEmail = _currentUserEmail;
      if (userEmail == null) {
        throw ServerException(message: 'User must be logged in to register');
      }

      final docRef = firestore.collection('events').doc(eventId);
      return await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw ServerException(message: 'Event not found');
        }

        final data = doc.data()!;
        final List<String> attendeeEmails =
            ((data['attendee_emails'] ?? data['attendeeEmails'])
                    as List<dynamic>?)
                ?.map((e) => e.toString().trim())
                .toList() ??
            [];

        if (attendeeEmails.contains(userEmail.trim())) {
          throw ServerException(message: 'Already registered');
        }

        final currentAttendees = (data['current_attendees'] as int? ?? 0);
        final maxAttendees = (data['max_attendees'] as int? ?? 0);

        if (maxAttendees != 0 && currentAttendees >= maxAttendees) {
          throw ServerException(message: 'Event is full');
        }

        transaction.update(docRef, {
          'current_attendees': currentAttendees + 1,
          'attendee_emails': FieldValue.arrayUnion([userEmail]),
        });

        return EventDto.fromJson({
          ...data,
          'id': doc.id,
          'current_attendees': currentAttendees + 1,
          'is_registered': true,
          'attendee_emails': [...attendeeEmails, userEmail],
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> unregisterFromEvent(String eventId) async {
    try {
      final userEmail = _currentUserEmail;
      if (userEmail == null) {
        throw ServerException(message: 'User must be logged in to unregister');
      }

      final docRef = firestore.collection('events').doc(eventId);
      return await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw ServerException(message: 'Event not found');
        }

        final data = doc.data()!;
        final List<String> attendeeEmails =
            ((data['attendee_emails'] ?? data['attendeeEmails'])
                    as List<dynamic>?)
                ?.map((e) => e.toString().trim())
                .toList() ??
            [];

        if (!attendeeEmails.contains(userEmail.trim())) {
          throw ServerException(message: 'Not registered for this event');
        }

        final currentAttendees = (data['current_attendees'] as int? ?? 0);

        transaction.update(docRef, {
          'current_attendees': currentAttendees > 0 ? currentAttendees - 1 : 0,
          'attendee_emails': FieldValue.arrayRemove([userEmail]),
        });

        return EventDto.fromJson({
          ...data,
          'id': doc.id,
          'current_attendees': currentAttendees > 0 ? currentAttendees - 1 : 0,
          'is_registered': false,
          'attendee_emails': attendeeEmails
              .where((e) => e != userEmail)
              .toList(),
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<EventDto>> getRegisteredEvents() async {
    try {
      final userEmail = _currentUserEmail;
      if (userEmail == null) return [];

      final trimmedEmail = userEmail.trim();

      final snapshot = await firestore
          .collection('events')
          .where('attendee_emails', arrayContains: trimmedEmail)
          .get();

      final events = snapshot.docs.map((doc) {
        return EventDto.fromJson({
          ...doc.data(),
          'id': doc.id,
          'is_registered': true,
        });
      }).toList();

      return events;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
