import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object?> get props => [];
}

class EventDetailsInitial extends EventDetailsState {}

class EventDetailsLoading extends EventDetailsState {}

class EventDetailsLoaded extends EventDetailsState {
  final Event event;

  const EventDetailsLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDetailsError extends EventDetailsState {
  final String message;

  const EventDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RegistrationInProgress extends EventDetailsState {
  final Event event;

  const RegistrationInProgress(this.event);

  @override
  List<Object?> get props => [event];
}

class RegistrationSuccess extends EventDetailsState {
  final Event event;
  final String message;

  const RegistrationSuccess(this.event, this.message);

  @override
  List<Object?> get props => [event, message];
}

class RegistrationError extends EventDetailsState {
  final Event event;
  final String message;

  const RegistrationError(this.event, this.message);

  @override
  List<Object?> get props => [event, message];
}
