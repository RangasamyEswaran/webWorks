import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<Event>>> getEvents({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, Event>> getEventDetails(String eventId);

  Future<Either<Failure, Event>> registerForEvent(String eventId);

  Future<Either<Failure, Event>> unregisterFromEvent(String eventId);

  Future<Either<Failure, List<Event>>> getRegisteredEvents();
}
