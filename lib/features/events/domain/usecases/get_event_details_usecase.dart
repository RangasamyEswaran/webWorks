import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetEventDetailsUseCase {
  final EventsRepository repository;

  GetEventDetailsUseCase(this.repository);

  Future<Either<Failure, Event>> call(String eventId) async {
    return await repository.getEventDetails(eventId);
  }
}
