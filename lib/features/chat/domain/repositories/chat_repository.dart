import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatMessage>>> getChatMessages(String eventId);
  Future<Either<Failure, void>> sendMessage(ChatMessage message);
}
