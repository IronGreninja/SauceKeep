import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themePrefKey = 'app_theme';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final savedTheme = prefs.getString(_themePrefKey);

    return switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    // Update the app immediately.
    state = mode;

    final prefs = ref.read(sharedPreferencesProvider);

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString(_themePrefKey, value);
  }
}
