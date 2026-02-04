import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../models/event_dto.dart';

abstract class EventsLocalDataSource {
  Future<void> cacheEvents(List<EventDto> events);
  Future<List<EventDto>> getCachedEvents();
  Future<void> cacheEventDetails(EventDto event);
  Future<EventDto?> getCachedEventDetails(String eventId);
  Future<void> clearCache();
}

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  late Box<Map> _eventsBox;

  EventsLocalDataSourceImpl() {
    _initBox();
  }

  Future<void> _initBox() async {
    _eventsBox = await Hive.openBox<Map>(StorageKeys.eventsBox);
  }

  @override
  Future<void> cacheEvents(List<EventDto> events) async {
    try {
      await _eventsBox.put('events_list', {
        'events': events.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw CacheException(message: 'Failed to cache events');
    }
  }

  @override
  Future<List<EventDto>> getCachedEvents() async {
    try {
      final data = _eventsBox.get('events_list');
      if (data != null) {
        final List<dynamic> eventsJson = data['events'] as List<dynamic>;
        return eventsJson
            .map((json) => EventDto.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException(message: 'Failed to get cached events');
    }
  }

  @override
  Future<void> cacheEventDetails(EventDto event) async {
    try {
      await _eventsBox.put('event_${event.id}', event.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache event details');
    }
  }

  @override
  Future<EventDto?> getCachedEventDetails(String eventId) async {
    try {
      final data = _eventsBox.get('event_$eventId');
      if (data != null) {
        return EventDto.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached event details');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _eventsBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }
}
