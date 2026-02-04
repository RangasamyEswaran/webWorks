import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatMessagesEvent extends ChatEvent {
  final String eventId;
  const LoadChatMessagesEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class SendMessageEvent extends ChatEvent {
  final String eventId;
  final String text;
  final String senderId;
  final String senderName;

  const SendMessageEvent({
    required this.eventId,
    required this.text,
    required this.senderId,
    required this.senderName,
  });

  @override
  List<Object?> get props => [eventId, text, senderId, senderName];
}

class ChatMessagesUpdatedEvent extends ChatEvent {
  final List<ChatMessage> messages;
  const ChatMessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatErrorEvent extends ChatEvent {
  final String message;
  const ChatErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
