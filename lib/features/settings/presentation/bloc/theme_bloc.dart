import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

const String _themeKey = 'isDarkMode';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(ThemeState(isDarkMode: sharedPreferences.getBool(_themeKey) ?? false)) {
    on<ToggleThemeEvent>((event, emit) async {
      final isDark = !state.isDarkMode;
      await sharedPreferences.setBool(_themeKey, isDark);
      emit(ThemeState(isDarkMode: isDark));
    });

    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPreferences.getBool(_themeKey) ?? false;
      emit(ThemeState(isDarkMode: isDark));
    });
  }
}
