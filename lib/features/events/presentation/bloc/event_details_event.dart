import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventDetailsEvent extends Equatable {
  const EventDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEventDetailsEvent extends EventDetailsEvent {
  final String eventId;

  const LoadEventDetailsEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class RegisterForEventEvent extends EventDetailsEvent {
  final String eventId;

  const RegisterForEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class UnregisterFromEventEvent extends EventDetailsEvent {
  final String eventId;

  const UnregisterFromEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventStatusUpdatedEvent extends EventDetailsEvent {
  final Event updatedEvent;

  const EventStatusUpdatedEvent(this.updatedEvent);

  @override
  List<Object?> get props => [updatedEvent];
}
