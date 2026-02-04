import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_dto.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ChatMessage>>> getChatMessages(String eventId) {
    return remoteDataSource.getChatMessages(eventId).map((dtos) {
      try {
        final messages = dtos.map((dto) => dto.toEntity()).toList();
        return Right(messages);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> sendMessage(ChatMessage message) async {
    try {
      final dto = ChatMessageDto(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        text: message.text,
        timestamp: message.timestamp,
        eventId: message.eventId,
      );
      await remoteDataSource.sendMessage(dto);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
