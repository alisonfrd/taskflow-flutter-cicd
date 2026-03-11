import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _prefKey = 'cyber_theme_preference';

  ThemeCubit() : super(const ThemeState(ThemePreference.system));

  /// Carrega a preferência salva no SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      final pref = ThemePreference.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemePreference.system,
      );
      emit(ThemeState(pref));
    }
  }

  Future<void> setTheme(ThemePreference preference) async {
    emit(ThemeState(preference));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, preference.name);
  }

  Future<void> toggle() async {
    final next = switch (state.preference) {
      ThemePreference.system => ThemePreference.dark,
      ThemePreference.dark => ThemePreference.light,
      ThemePreference.light => ThemePreference.system,
    };
    await setTheme(next);
  }
}
