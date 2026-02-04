import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String eventId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.eventId,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    text,
    timestamp,
    eventId,
  ];
}
