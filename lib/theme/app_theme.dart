import 'package:flutter/material.dart';

class AppTheme {
  static final Color _lightPrimary = const Color(0xFF6200EE);
  static final Color _lightPrimaryVariant = const Color(0xFF3700B3);
  static final Color _lightSecondary = const Color(0xFF03DAC5);
  static final Color _lightBackground = Colors.white;
  static final Color _lightSurface = Colors.white;
  static final Color _lightOnPrimary = Colors.white;
  static final Color _lightOnSecondary = Colors.black;
  static final Color _lightOnSurface = Colors.black;
  static final Color _lightError = Colors.red.shade700;

  static final Color _darkPrimary = const Color(0xFFBB86FC);
  static final Color _darkPrimaryVariant = const Color(0xFF3700B3);
  static final Color _darkSecondary = const Color(0xFF03DAC5);
  static final Color _darkBackground = const Color(0xFF121212);
  static final Color _darkSurface = const Color(0xFF1E1E1E);
  static final Color _darkOnPrimary = Colors.black;
  static final Color _darkOnSecondary = Colors.black;
  static final Color _darkOnSurface = Colors.white;
  static final Color _darkError = Colors.red.shade400;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimary,
    primaryColorDark: _lightPrimaryVariant,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      background: _lightBackground,
      onPrimary: _lightOnPrimary,
      onSecondary: _lightOnSecondary,
      onSurface: _lightOnSurface,
      onBackground: _lightOnSurface,
      error: _lightError,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: AppBarTheme(
      color: _lightPrimary,
      iconTheme: IconThemeData(color: _lightOnPrimary),
      toolbarTextStyle:
          TextTheme(
            titleLarge: TextStyle(
              color: _lightOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).bodyMedium,
      titleTextStyle:
          TextTheme(
            titleLarge: TextStyle(
              color: _lightOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).titleLarge,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightSecondary,
      foregroundColor: _lightOnSecondary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightSurface,
      titleTextStyle: TextStyle(
        color: _lightOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: _lightOnSurface, fontSize: 16),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightPrimary),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      color: _lightSurface,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimary,
    primaryColorDark: _darkPrimaryVariant,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      background: _darkBackground,
      onPrimary: _darkOnPrimary,
      onSecondary: _darkOnSecondary,
      onSurface: _darkOnSurface,
      onBackground: _darkOnSurface,
      error: _darkError,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: AppBarTheme(
      color: _darkSurface,
      iconTheme: IconThemeData(color: _darkOnSurface),
      toolbarTextStyle:
          TextTheme(
            titleLarge: TextStyle(
              color: _darkOnSurface,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).bodyMedium,
      titleTextStyle:
          TextTheme(
            titleLarge: TextStyle(
              color: _darkOnSurface,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).titleLarge,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkSecondary,
      foregroundColor: _darkOnSecondary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkSurface,
      titleTextStyle: TextStyle(
        color: _darkOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: _darkOnSurface, fontSize: 16),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkSecondary),
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      color: _darkSurface,
      shadowColor: Colors.black.withOpacity(0.5),
    ),
  );
}
