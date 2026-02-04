import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_registered_events_usecase.dart';
import 'registered_events_event.dart';
import 'registered_events_state.dart';

class RegisteredEventsBloc
    extends Bloc<RegisteredEventsEvent, RegisteredEventsState> {
  final GetRegisteredEventsUseCase getRegisteredEventsUseCase;

  RegisteredEventsBloc({required this.getRegisteredEventsUseCase})
    : super(RegisteredEventsInitial()) {
    on<LoadRegisteredEventsEvent>(_onLoadRegisteredEvents);
    on<RefreshRegisteredEventsEvent>(_onRefreshRegisteredEvents);
  }

  Future<void> _onLoadRegisteredEvents(
    LoadRegisteredEventsEvent event,
    Emitter<RegisteredEventsState> emit,
  ) async {
    emit(RegisteredEventsLoading());

    final result = await getRegisteredEventsUseCase();

    result.fold(
      (failure) => emit(RegisteredEventsError(failure.message)),
      (events) => emit(RegisteredEventsLoaded(events: events)),
    );
  }

  Future<void> _onRefreshRegisteredEvents(
    RefreshRegisteredEventsEvent event,
    Emitter<RegisteredEventsState> emit,
  ) async {
    final result = await getRegisteredEventsUseCase();

    result.fold((failure) {
      if (state is! RegisteredEventsLoaded) {
        emit(RegisteredEventsError(failure.message));
      }
    }, (events) => emit(RegisteredEventsLoaded(events: events)));
  }
}
