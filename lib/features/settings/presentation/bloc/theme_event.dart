import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeColor extends ThemeEvent {
  final Color color;

  const ChangeThemeColor(this.color);

  @override
  List<Object> get props => [color];
}
