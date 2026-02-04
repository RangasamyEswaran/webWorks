import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetRegisteredEventsUseCase {
  final EventsRepository repository;

  GetRegisteredEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call() async {
    return await repository.getRegisteredEvents();
  }
}
