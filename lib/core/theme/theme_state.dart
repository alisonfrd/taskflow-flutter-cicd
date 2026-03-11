import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Representa a preferência de tema do usuário.
enum ThemePreference {
  /// Segue o tema do sistema operacional.
  system,

  /// Sempre usa tema dark.
  dark,

  /// Sempre usa tema light.
  light,
}

class ThemeState extends Equatable {
  final ThemePreference preference;

  const ThemeState(this.preference);

  ThemeMode get themeMode => switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.light => ThemeMode.light,
  };

  @override
  List<Object?> get props => [preference];
}
