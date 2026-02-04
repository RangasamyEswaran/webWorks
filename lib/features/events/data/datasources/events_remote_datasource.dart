import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/event_dto.dart';

abstract class EventsRemoteDataSource {
  Future<List<EventDto>> getEvents({required int page, required int pageSize});

  Future<EventDto> getEventDetails(String eventId);

  Future<EventDto> registerForEvent(String eventId);

  Future<EventDto> unregisterFromEvent(String eventId);

  Future<List<EventDto>> getRegisteredEvents();
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiClient apiClient;

  EventsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<EventDto>> getEvents({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConfig.events,
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> eventsJson = data['events'] ?? data['data'] ?? data;
        return eventsJson.map((json) => EventDto.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch events',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Failed to fetch events',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> getEventDetails(String eventId) async {
    try {
      final response = await apiClient.get(ApiConfig.eventDetails(eventId));

      if (response.statusCode == 200) {
        final data = response.data['event'] ?? response.data;
        return EventDto.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch event details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message:
              e.response?.data['message'] ?? 'Failed to fetch event details',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    try {
      final response = await apiClient.post(ApiConfig.registerEvent(eventId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['event'] ?? response.data;
        return EventDto.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to register for event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message:
              e.response?.data['message'] ?? 'Failed to register for event',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventDto> unregisterFromEvent(String eventId) async {
    try {
      final response = await apiClient.post(ApiConfig.unregisterEvent(eventId));

      if (response.statusCode == 200) {
        final data = response.data['event'] ?? response.data;
        return EventDto.fromJson(data);
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to unregister from event',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message:
              e.response?.data['message'] ?? 'Failed to unregister from event',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventDto>> getRegisteredEvents() async {
    throw UnimplementedError();
  }
}
