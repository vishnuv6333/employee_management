import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;
  final Color seedColor;

  const ThemeState({
    required this.isDarkMode,
    this.seedColor = Colors.deepPurple,
  });

  @override
  List<Object> get props => [isDarkMode, seedColor];
}
