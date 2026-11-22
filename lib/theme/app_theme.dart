import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: lightColorScheme,

    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightColorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: lightColorScheme.onInverseSurface,
      ),
      actionTextColor: lightColorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,

    colorScheme: darkColorScheme,

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkColorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: darkColorScheme.onInverseSurface,
      ),
      actionTextColor: darkColorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final seedColor = const Color(0xFF6750A4);

  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
}
