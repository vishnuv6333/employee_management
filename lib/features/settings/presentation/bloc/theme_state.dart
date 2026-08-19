import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;
  final Color seedColor;
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;

  const ThemeState({
    required this.isDarkMode,
    this.seedColor = Colors.deepPurple,
    this.dailyReminderEnabled = false,
    this.dailyReminderTime = const TimeOfDay(hour: 9, minute: 0),
  });

  ThemeState copyWith({
    bool? isDarkMode,
    Color? seedColor,
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      seedColor: seedColor ?? this.seedColor,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }

  @override
  List<Object> get props => [isDarkMode, seedColor, dailyReminderEnabled, dailyReminderTime];
}
