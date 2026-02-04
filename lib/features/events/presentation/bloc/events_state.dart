import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  final bool hasMore;
  final int currentPage;

  const EventsLoaded({
    required this.events,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [events, hasMore, currentPage];

  EventsLoaded copyWith({
    List<Event>? events,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventsLoaded(
      events: events ?? this.events,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class EventsLoadingMore extends EventsState {
  final List<Event> events;
  final int currentPage;

  const EventsLoadingMore({required this.events, required this.currentPage});

  @override
  List<Object?> get props => [events, currentPage];
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
