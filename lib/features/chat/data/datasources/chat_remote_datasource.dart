import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_dto.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageDto>> getChatMessages(String eventId);
  Future<void> sendMessage(ChatMessageDto message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChatMessageDto>> getChatMessages(String eventId) {
    return firestore
        .collection('events')
        .doc(eventId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessageDto.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> sendMessage(ChatMessageDto message) async {
    await firestore
        .collection('events')
        .doc(message.eventId)
        .collection('messages')
        .add(message.toJson());
  }
}
