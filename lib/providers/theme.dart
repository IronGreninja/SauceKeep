import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences.dart';
import '../theme/app_theme.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    final prefs = ref.read(sharedPrefsProvider);
    final themeModeStr = prefs.getString(PrefsKeys.themeMode);
    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final seedValue = prefs.getInt(PrefsKeys.themeSeedColor);
    final useDynamic = prefs.getBool(PrefsKeys.themeUseDynamic);

    return ThemeSettings(
      themeMode: themeMode,
      seedColor: seedValue != null ? Color(seedValue) : appSwatches.first.color,
      useDynamicColor: useDynamic ?? false,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;

    state = state.copyWith(themeMode: mode);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await ref.read(sharedPrefsProvider).setString(PrefsKeys.themeMode, value);
  }

  Future<void> setSeedColor(Color color) async {
    if (state.seedColor.toARGB32() == color.toARGB32()) return;
    state = state.copyWith(seedColor: color);
    await ref
        .read(sharedPrefsProvider)
        .setInt(PrefsKeys.themeSeedColor, color.toARGB32());
  }

  Future<void> setUseDynamicColor(bool value) async {
    if (state.useDynamicColor == value) return;
    state = state.copyWith(useDynamicColor: value);
    await ref
        .read(sharedPrefsProvider)
        .setBool(PrefsKeys.themeUseDynamic, value);
  }

  Future<void> resetToDefaults() async {
    state = ThemeSettings(
      themeMode: ThemeMode.system,
      seedColor: appSwatches.first.color,
      useDynamicColor: false,
    );
    final prefs = ref.read(sharedPrefsProvider);
    await Future.wait([
      prefs.setString(PrefsKeys.themeMode, 'system'),
      prefs.setInt(
        PrefsKeys.themeSeedColor,
        appSwatches.first.color.toARGB32(),
      ),
      prefs.setBool(PrefsKeys.themeUseDynamic, false),
    ]);
  }
}

@immutable
class ThemeSettings {
  final ThemeMode themeMode;
  final Color seedColor;
  final bool useDynamicColor;

  const ThemeSettings({
    required this.themeMode,
    required this.seedColor,
    required this.useDynamicColor,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    bool? useDynamicColor,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettings &&
          themeMode == other.themeMode &&
          seedColor.toARGB32() == other.seedColor.toARGB32() &&
          useDynamicColor == other.useDynamicColor;

  @override
  int get hashCode =>
      Object.hash(themeMode, seedColor.toARGB32(), useDynamicColor);
}
