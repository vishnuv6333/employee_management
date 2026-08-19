import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

const String _themeModeKey = 'isDarkMode';
const String _themeColorKey = 'seedColor';
const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
const String _dailyReminderHourKey = 'daily_reminder_hour';
const String _dailyReminderMinuteKey = 'daily_reminder_minute';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(ThemeState(
          isDarkMode: sharedPreferences.getBool(_themeModeKey) ?? false,
          seedColor: Color(sharedPreferences.getInt(_themeColorKey) ?? Colors.deepPurple.value),
          dailyReminderEnabled: sharedPreferences.getBool(_dailyReminderEnabledKey) ?? false,
          dailyReminderTime: TimeOfDay(
            hour: sharedPreferences.getInt(_dailyReminderHourKey) ?? 9,
            minute: sharedPreferences.getInt(_dailyReminderMinuteKey) ?? 0,
          ),
        )) {
    on<ToggleThemeEvent>((event, emit) async {
      final isDark = !state.isDarkMode;
      await sharedPreferences.setBool(_themeModeKey, isDark);
      emit(state.copyWith(isDarkMode: isDark));
    });

    on<ChangeThemeColor>((event, emit) async {
      await sharedPreferences.setInt(_themeColorKey, event.color.value);
      emit(state.copyWith(seedColor: event.color));
    });

    on<UpdateDailyReminderEvent>((event, emit) async {
      await sharedPreferences.setBool(_dailyReminderEnabledKey, event.enabled);
      await sharedPreferences.setInt(_dailyReminderHourKey, event.time.hour);
      await sharedPreferences.setInt(_dailyReminderMinuteKey, event.time.minute);
      emit(state.copyWith(
        dailyReminderEnabled: event.enabled,
        dailyReminderTime: event.time,
      ));
    });

    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPreferences.getBool(_themeModeKey) ?? false;
      final seedColor = Color(sharedPreferences.getInt(_themeColorKey) ?? Colors.deepPurple.value);
      final dailyReminderEnabled = sharedPreferences.getBool(_dailyReminderEnabledKey) ?? false;
      final dailyReminderTime = TimeOfDay(
        hour: sharedPreferences.getInt(_dailyReminderHourKey) ?? 9,
        minute: sharedPreferences.getInt(_dailyReminderMinuteKey) ?? 0,
      );
      emit(state.copyWith(
        isDarkMode: isDark,
        seedColor: seedColor,
        dailyReminderEnabled: dailyReminderEnabled,
        dailyReminderTime: dailyReminderTime,
      ));
    });
  }
}
