import 'package:equatable/equatable.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventsEvent extends EventsEvent {}

class LoadMoreEventsEvent extends EventsEvent {}

class RefreshEventsEvent extends EventsEvent {}
