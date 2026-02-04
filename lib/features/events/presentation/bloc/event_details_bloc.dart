import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/events_socket_datasource.dart';
import '../../domain/usecases/get_event_details_usecase.dart';
import '../../domain/usecases/register_event_usecase.dart';
import '../../domain/usecases/unregister_event_usecase.dart';
import 'event_details_event.dart';
import 'event_details_state.dart';

class EventDetailsBloc extends Bloc<EventDetailsEvent, EventDetailsState> {
  final GetEventDetailsUseCase getEventDetailsUseCase;
  final RegisterEventUseCase registerEventUseCase;
  final UnregisterEventUseCase unregisterEventUseCase;

  EventDetailsBloc({
    required this.getEventDetailsUseCase,
    required this.registerEventUseCase,
    required this.unregisterEventUseCase,
    required EventsSocketDataSource socketDataSource,
  }) : super(EventDetailsInitial()) {
    on<LoadEventDetailsEvent>(_onLoadEventDetails);
    on<RegisterForEventEvent>(_onRegisterForEvent);
    on<UnregisterFromEventEvent>(_onUnregisterFromEvent);
    on<EventStatusUpdatedEvent>(_onEventStatusUpdated);
  }

  Future<void> _onLoadEventDetails(
    LoadEventDetailsEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    emit(EventDetailsLoading());

    final result = await getEventDetailsUseCase(event.eventId);

    result.fold(
      (failure) => emit(EventDetailsError(failure.message)),
      (eventDetails) => emit(EventDetailsLoaded(eventDetails)),
    );
  }

  Future<void> _onRegisterForEvent(
    RegisterForEventEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded) {
      emit(RegistrationInProgress(currentState.event));

      final result = await registerEventUseCase(event.eventId);

      result.fold(
        (failure) =>
            emit(RegistrationError(currentState.event, failure.message)),
        (updatedEvent) => emit(
          RegistrationSuccess(
            updatedEvent,
            'Successfully registered for event',
          ),
        ),
      );
    }
  }

  Future<void> _onUnregisterFromEvent(
    UnregisterFromEventEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailsLoaded) {
      emit(RegistrationInProgress(currentState.event));

      final result = await unregisterEventUseCase(event.eventId);

      result.fold(
        (failure) =>
            emit(RegistrationError(currentState.event, failure.message)),
        (updatedEvent) => emit(
          RegistrationSuccess(
            updatedEvent,
            'Successfully unregistered from event',
          ),
        ),
      );
    }
  }

  Future<void> _onEventStatusUpdated(
    EventStatusUpdatedEvent event,
    Emitter<EventDetailsState> emit,
  ) async {
    emit(EventDetailsLoaded(event.updatedEvent));
  }
}
