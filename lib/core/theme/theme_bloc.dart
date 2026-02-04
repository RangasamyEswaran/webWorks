import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ThemeChangedEvent>((event, emit) {
      emit(ThemeState(event.themeMode));
    });

    on<ToggleThemeEvent>((event, emit) {
      final newMode = state.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
      emit(ThemeState(newMode));
    });
  }
}
