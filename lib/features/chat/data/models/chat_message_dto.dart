import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageDto {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String eventId;

  ChatMessageDto({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.eventId,
  });

  factory ChatMessageDto.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return ChatMessageDto(
      id: documentId,
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventId: json['event_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'event_id': eventId,
    };
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: timestamp,
      eventId: eventId,
    );
  }
}
