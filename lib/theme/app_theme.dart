import 'package:flutter/material.dart';

class AppTheme {
  // Base colors for light theme
  static final Color _lightSeedColor = Colors.deepPurple;
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _lightSeedColor,
    brightness: Brightness.light,
  );

  // Base colors for dark theme
  static final Color _darkSeedColor = Colors.deepPurple;
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _darkSeedColor,
    brightness: Brightness.dark,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primaryContainer,
      foregroundColor: _lightColorScheme.onPrimaryContainer,
      elevation: 2,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightColorScheme.surface,
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightColorScheme.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
    ),
    cardTheme: CardTheme(
      elevation: 1.0,
      color: _lightColorScheme.surfaceContainerHighest,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _lightColorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outlineVariant,
      thickness: 0.5,
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom()),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkColorScheme.surfaceContainerHigh,
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkColorScheme.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
    ),
    cardTheme: CardTheme(
      elevation: 1.0,
      color: _darkColorScheme.surfaceContainerHighest,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _darkColorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outlineVariant,
      thickness: 0.5,
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom()),
  );
}
