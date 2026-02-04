import 'package:equatable/equatable.dart';

abstract class RegisteredEventsEvent extends Equatable {
  const RegisteredEventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRegisteredEventsEvent extends RegisteredEventsEvent {}

class RefreshRegisteredEventsEvent extends RegisteredEventsEvent {}
