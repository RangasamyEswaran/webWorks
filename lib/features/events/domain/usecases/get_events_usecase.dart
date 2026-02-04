import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetEventsUseCase {
  final EventsRepository repository;

  GetEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call({
    required int page,
    required int pageSize,
  }) async {
    return await repository.getEvents(page: page, pageSize: pageSize);
  }
}
