import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Stream<Either<Failure, List<ChatMessage>>> call(String eventId) {
    return repository.getChatMessages(eventId);
  }
}
