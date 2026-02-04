import 'package:equatable/equatable.dart';
import '../../../domain/entities/event.dart';

abstract class EventDetailsState extends Equatable {
  const EventDetailsState();

  @override
  List<Object?> get props => [];
}

class EventDetailsInitial extends EventDetailsState {}

class EventDetailsLoading extends EventDetailsState {}

class EventDetailsLoaded extends EventDetailsState {
  final Event event;
  final bool isRegistering;

  const EventDetailsLoaded({required this.event, this.isRegistering = false});

  EventDetailsLoaded copyWith({Event? event, bool? isRegistering}) {
    return EventDetailsLoaded(
      event: event ?? this.event,
      isRegistering: isRegistering ?? this.isRegistering,
    );
  }

  @override
  List<Object?> get props => [event, isRegistering];
}

class EventDetailsError extends EventDetailsState {
  final String message;

  const EventDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
