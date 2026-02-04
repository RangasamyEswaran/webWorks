import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_local_datasource.dart';
import '../datasources/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;
  final EventsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    required int page,
    required int pageSize,
  }) async {
    if (!await networkInfo.isConnected) {
      try {
        final cachedEvents = await localDataSource.getCachedEvents();
        if (cachedEvents.isNotEmpty) {
          return Right(cachedEvents.map((dto) => dto.toEntity()).toList());
        }
        return const Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      } catch (e) {
        return const Left(CacheFailure('Failed to load cached events'));
      }
    }

    try {
      final events = await remoteDataSource.getEvents(
        page: page,
        pageSize: pageSize,
      );

      if (page == 1) {
        await localDataSource.cacheEvents(events);
      }

      return Right(events.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(String eventId) async {
    try {
      final cachedEvent = await localDataSource.getCachedEventDetails(eventId);
      if (cachedEvent != null && !await networkInfo.isConnected) {
        return Right(cachedEvent.toEntity());
      }

      if (await networkInfo.isConnected) {
        final event = await remoteDataSource.getEventDetails(eventId);
        await localDataSource.cacheEventDetails(event);
        return Right(event.toEntity());
      }

      if (cachedEvent != null) {
        return Right(cachedEvent.toEntity());
      }

      return const Left(NetworkFailure('No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> registerForEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final event = await remoteDataSource.registerForEvent(eventId);
      await localDataSource.cacheEventDetails(event);
      return Right(event.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> unregisterFromEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final event = await remoteDataSource.unregisterFromEvent(eventId);
      await localDataSource.cacheEventDetails(event);
      return Right(event.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getRegisteredEvents() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final events = await remoteDataSource.getRegisteredEvents();
      return Right(events.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
