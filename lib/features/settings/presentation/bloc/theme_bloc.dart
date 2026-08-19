import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

const String _themeModeKey = 'isDarkMode';
const String _themeColorKey = 'seedColor';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(ThemeState(
          isDarkMode: sharedPreferences.getBool(_themeModeKey) ?? false,
          seedColor: Color(sharedPreferences.getInt(_themeColorKey) ?? Colors.deepPurple.value),
        )) {
    on<ToggleThemeEvent>((event, emit) async {
      final isDark = !state.isDarkMode;
      await sharedPreferences.setBool(_themeModeKey, isDark);
      emit(ThemeState(isDarkMode: isDark, seedColor: state.seedColor));
    });

    on<ChangeThemeColor>((event, emit) async {
      await sharedPreferences.setInt(_themeColorKey, event.color.value);
      emit(ThemeState(isDarkMode: state.isDarkMode, seedColor: event.color));
    });

    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPreferences.getBool(_themeModeKey) ?? false;
      final seedColor = Color(sharedPreferences.getInt(_themeColorKey) ?? Colors.deepPurple.value);
      emit(ThemeState(isDarkMode: isDark, seedColor: seedColor));
    });
  }
}
