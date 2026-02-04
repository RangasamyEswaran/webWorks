import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/events_socket_datasource.dart';
import '../../../domain/usecases/get_event_details_usecase.dart';
import '../../../domain/usecases/register_event_usecase.dart';
import '../../../domain/usecases/unregister_event_usecase.dart';
import '../../../domain/entities/event.dart';
import 'event_details_event.dart';
import 'event_details_state.dart';
import '../../../../../core/services/notification_service.dart';

class EventDetailsBloc extends Bloc<EventDetailsEvent, EventDetailsState> {
  final GetEventDetailsUseCase getEventDetailsUseCase;
  final RegisterEventUseCase registerEventUseCase;
  final UnregisterEventUseCase unregisterEventUseCase;
  final EventsSocketDataSource socketDataSource;
  final NotificationService notificationService;
  StreamSubscription? _socketSubscription;

  EventDetailsBloc({
    required this.getEventDetailsUseCase,
    required this.registerEventUseCase,
    required this.unregisterEventUseCase,
    required this.socketDataSource,
    required this.notificationService,
  }) : super(EventDetailsInitial()) {
    on<LoadEventDetailsEvent>(_onLoadEventDetails);
    on<RegisterForEventEvent>(_onRegisterForEvent);
    on<UnregisterFromEventEvent>(_onUnregisterFromEvent);
    on<EventUpdateReceivedEvent>(_onEventUpdateReceived);
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadEventDetails(
    LoadEventDetailsEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    emit(EventDetailsLoading());

    final result = await getEventDetailsUseCase(event.eventId);

    result.fold((failure) => emit(EventDetailsError(failure.message)), (
      eventData,
    ) {
      if (eventData.isRegistered) {
        _scheduleReminder(eventData);
        notificationService.subscribeToTopic('event_${eventData.id}');
      }
      emit(EventDetailsLoaded(event: eventData));
      _subscribeToSocket(event.eventId);
    });
  }

  Future<void> _onRegisterForEvent(
    RegisterForEventEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded) {
      emit(currentState.copyWith(isRegistering: true));

      final result = await registerEventUseCase(event.eventId);

      result.fold((failure) => emit(EventDetailsError(failure.message)), (
        updatedEvent,
      ) {
        _scheduleReminder(updatedEvent);
        notificationService.subscribeToTopic('event_${updatedEvent.id}');
        emit(currentState.copyWith(event: updatedEvent, isRegistering: false));
      });
    }
  }

  Future<void> _onUnregisterFromEvent(
    UnregisterFromEventEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded) {
      emit(currentState.copyWith(isRegistering: true));

      final result = await unregisterEventUseCase(event.eventId);

      result.fold((failure) => emit(EventDetailsError(failure.message)), (
        updatedEvent,
      ) {
        _cancelReminder(updatedEvent.id.hashCode);
        notificationService.unsubscribeFromTopic('event_${updatedEvent.id}');
        emit(currentState.copyWith(event: updatedEvent, isRegistering: false));
      });
    }
  }

  void _subscribeToSocket(String eventId) {
    socketDataSource.subscribeToEvent(eventId);
    _socketSubscription?.cancel();
    _socketSubscription = socketDataSource.eventUpdates.listen((eventDto) {
      add(EventUpdateReceivedEvent(eventDto.toEntity()));
    });
  }

  Future<void> _onEventUpdateReceived(
    EventUpdateReceivedEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded) {
      if (currentState.event.id == event.event.id) {
        emit(currentState.copyWith(event: event.event));
      }
    }
  }

  void _scheduleReminder(Event event) {
    final reminderTime = event.startDate.subtract(const Duration(hours: 1));
    notificationService.scheduleEventReminder(
      id: event.id.hashCode,
      title: 'Event Reminder',
      body: '${event.title} is starting in 1 hour!',
      scheduledDate: reminderTime,
      payload: event.id,
    );
  }

  void _cancelReminder(int id) {
    notificationService.cancelNotification(id);
  }
}
