import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/events/data/models/event_dto.dart';

class FirestoreMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> uploadDummyEvents(List<EventDto> events) async {
    final CollectionReference eventsCollection = _firestore.collection(
      'events',
    );

    for (final event in events) {
      try {
        await eventsCollection.doc(event.id).set(event.toJson());
        print('Successfully uploaded event: ${event.title}');
      } catch (e) {
        print('Error uploading event ${event.title}: $e');
      }
    }
    print('Firestore migration completed.');
  }
}
