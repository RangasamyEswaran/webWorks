import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class UnregisterEventUseCase {
  final EventsRepository repository;

  UnregisterEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(String eventId) async {
    return await repository.unregisterFromEvent(eventId);
  }
}
