import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class RegisteredEventsState extends Equatable {
  const RegisteredEventsState();

  @override
  List<Object?> get props => [];
}

class RegisteredEventsInitial extends RegisteredEventsState {}

class RegisteredEventsLoading extends RegisteredEventsState {}

class RegisteredEventsLoaded extends RegisteredEventsState {
  final List<Event> events;

  const RegisteredEventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class RegisteredEventsError extends RegisteredEventsState {
  final String message;

  const RegisteredEventsError(this.message);

  @override
  List<Object?> get props => [message];
}
