import 'dart:async';
import '../../../../core/network/socket_service.dart';
import '../models/event_dto.dart';

abstract class EventsSocketDataSource {
  Stream<EventDto> get eventUpdates;
  void subscribeToEvent(String eventId);
  void unsubscribeFromEvent(String eventId);
}

class EventsSocketDataSourceImpl implements EventsSocketDataSource {
  final SocketService _socketService;
  final _controller = StreamController<EventDto>.broadcast();

  EventsSocketDataSourceImpl(this._socketService) {
    _socketService.on('event_update', (data) {
      try {
        final event = EventDto.fromJson(data);
        _controller.add(event);
      } catch (e) {
        print('Error parsing event update: $e');
      }
    });
  }

  @override
  Stream<EventDto> get eventUpdates => _controller.stream;

  @override
  void subscribeToEvent(String eventId) {
    _socketService.connect();
  }

  @override
  void unsubscribeFromEvent(String eventId) {}
}
