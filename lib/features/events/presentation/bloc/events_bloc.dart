import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/get_events_usecase.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEventsUseCase getEventsUseCase;

  EventsBloc({required this.getEventsUseCase}) : super(EventsInitial()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<LoadMoreEventsEvent>(_onLoadMoreEvents);
    on<RefreshEventsEvent>(_onRefreshEvents);
  }

  Future<void> _onLoadEvents(
    LoadEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());

    final result = await getEventsUseCase(
      page: AppConstants.initialPage,
      pageSize: AppConstants.pageSize,
    );

    result.fold(
      (failure) => emit(EventsError(failure.message)),
      (events) => emit(
        EventsLoaded(
          events: events,
          hasMore: events.length >= AppConstants.pageSize,
          currentPage: AppConstants.initialPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreEvents(
    LoadMoreEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventsLoaded && currentState.hasMore) {
      emit(
        EventsLoadingMore(
          events: currentState.events,
          currentPage: currentState.currentPage,
        ),
      );

      final nextPage = currentState.currentPage + 1;
      final result = await getEventsUseCase(
        page: nextPage,
        pageSize: AppConstants.pageSize,
      );

      result.fold((failure) => emit(currentState), (newEvents) {
        final allEvents = [...currentState.events, ...newEvents];
        emit(
          EventsLoaded(
            events: allEvents,
            hasMore: newEvents.length >= AppConstants.pageSize,
            currentPage: nextPage,
          ),
        );
      });
    }
  }

  Future<void> _onRefreshEvents(
    RefreshEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    final result = await getEventsUseCase(
      page: AppConstants.initialPage,
      pageSize: AppConstants.pageSize,
    );

    result.fold(
      (failure) {
        if (state is EventsLoaded) {
        } else {
          emit(EventsError(failure.message));
        }
      },
      (events) => emit(
        EventsLoaded(
          events: events,
          hasMore: events.length >= AppConstants.pageSize,
          currentPage: AppConstants.initialPage,
        ),
      ),
    );
  }
}
