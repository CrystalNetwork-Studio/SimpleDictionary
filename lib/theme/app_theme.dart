import 'package:flutter/material.dart';

class AppTheme {
  // Base colors for light theme (Catppuccin Latte)
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _CatppuccinColors.latteBlue, // Using Blue as the primary seed
    brightness: Brightness.light,
    // Override specific colors for better Catppuccin Latte mapping
    background: _CatppuccinColors.latteBase,
    surface: _CatppuccinColors.latteMantle,
    onSurface: _CatppuccinColors.latteText,
    onBackground: _CatppuccinColors.latteText,
    primary: _CatppuccinColors.latteBlue,
    onPrimary: _CatppuccinColors.latteBase, // High contrast text on primary
    secondary: _CatppuccinColors.latteMauve, // Using Mauve as secondary
    onSecondary: _CatppuccinColors.latteBase, // High contrast text on secondary
    error: _CatppuccinColors.latteRed,
    onError: _CatppuccinColors.latteBase,
    surfaceVariant:
        _CatppuccinColors.latteSurface0, // Use for card/dialog backgrounds etc.
    onSurfaceVariant:
        _CatppuccinColors.latteSubtext0, // Text on surface variants
    outline: _CatppuccinColors.latteSurface1, // Borders
    outlineVariant: _CatppuccinColors.latteSurface0, // Subtle borders/dividers
  );

  // Base colors for dark theme (Catppuccin Mocha)
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _CatppuccinColors.mochaBlue, // Using Blue as the primary seed
    brightness: Brightness.dark,
    // Override specific colors for better Catppuccin Mocha mapping
    background: _CatppuccinColors.mochaBase,
    surface: _CatppuccinColors.mochaMantle, // Use for AppBars, Cards, Dialogs
    onSurface: _CatppuccinColors.mochaText,
    onBackground: _CatppuccinColors.mochaText,
    primary: _CatppuccinColors.mochaBlue,
    onPrimary: _CatppuccinColors.mochaCrust, // High contrast text on primary
    secondary: _CatppuccinColors.mochaMauve, // Using Mauve as secondary
    onSecondary:
        _CatppuccinColors.mochaCrust, // High contrast text on secondary
    error: _CatppuccinColors.mochaRed,
    onError: _CatppuccinColors.mochaCrust,
    surfaceVariant:
        _CatppuccinColors
            .mochaSurface0, // Use for input fields, chip backgrounds
    onSurfaceVariant:
        _CatppuccinColors.mochaSubtext0, // Text on surface variants
    outline: _CatppuccinColors.mochaSurface1, // Borders
    outlineVariant: _CatppuccinColors.mochaSurface0, // Subtle borders/dividers
  );

  // Light Theme (Latte)
  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface, // Mantle
      foregroundColor: _lightColorScheme.onSurface, // Text
      elevation: 0, // Catppuccin often uses flat designs
      surfaceTintColor: Colors.transparent, // Prevent M3 tinting
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary, // Blue
      foregroundColor: _lightColorScheme.onPrimary, // Base
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightColorScheme.surface, // Mantle
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface, // Text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant, // Subtext0
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary, // Blue
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary, // Blue
        foregroundColor: _lightColorScheme.onPrimary, // Base
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceVariant, // Surface0
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _lightColorScheme.primary, // Blue
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
      ), // Subtext0
      hintStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant.withOpacity(0.7),
      ), // Subtext0 slightly faded
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ), // Consistent padding
    ),
    cardTheme: CardTheme(
      elevation: 0, // Flat design
      color: _lightColorScheme.surface, // Mantle
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _lightColorScheme.onSurfaceVariant, // Subtext0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent, // Make list tiles transparent on Latte
    ),
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outlineVariant, // Surface0
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _lightColorScheme.onSurfaceVariant, // Subtext0
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _lightColorScheme.surfaceVariant, // Surface0
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
      ), // Subtext0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4, // Slight elevation to distinguish
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _lightColorScheme.surface, // Mantle
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      textStyle: TextStyle(color: _lightColorScheme.onSurface), // Text
    ),
  );

  // Dark Theme (Mocha)
  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkColorScheme.background, // Base
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface, // Mantle
      foregroundColor: _darkColorScheme.onSurface, // Text
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary, // Blue
      foregroundColor: _darkColorScheme.onPrimary, // Crust
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkColorScheme.surface, // Mantle
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface, // Text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant, // Subtext0
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkColorScheme.primary, // Blue
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary, // Blue
        foregroundColor: _darkColorScheme.onPrimary, // Crust
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceVariant, // Surface0
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.primary, // Blue
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
      ), // Subtext0
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant.withOpacity(0.7),
      ), // Subtext0 slightly faded
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: _darkColorScheme.surface, // Mantle
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _darkColorScheme.onSurfaceVariant, // Subtext0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent, // Make list tiles transparent on Mocha
    ),
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outlineVariant, // Surface0
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _darkColorScheme.onSurfaceVariant, // Subtext0
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkColorScheme.surfaceVariant, // Surface0
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
      ), // Subtext0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _darkColorScheme.surface, // Mantle
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      textStyle: TextStyle(color: _darkColorScheme.onSurface), // Text
    ),
  );
}

// Catppuccin Color Definitions
class _CatppuccinColors {
  // Latte
  static const Color latteMauve = Color(0xff8839ef);
  static const Color latteRed = Color(0xffd20f39);
  static const Color latteBlue = Color(0xff1e66f5); // Primary accent
  static const Color latteText = Color(0xff4c4f69);
  static const Color latteSubtext0 = Color(0xff6c6f85);
  static const Color latteSurface1 = Color(0xffbcc0cc);
  static const Color latteSurface0 = Color(0xffccd0da);
  static const Color latteBase = Color(0xffeff1f5); // Background
  static const Color latteMantle = Color(0xffe6e9ef); // Surface

  // Mocha
  static const Color mochaMauve = Color(0xffcba6f7);
  static const Color mochaRed = Color(0xfff38ba8);
  static const Color mochaBlue = Color(0xff89b4fa); // Primary accent
  static const Color mochaText = Color(0xffcdd6f4);
  static const Color mochaSubtext0 = Color(0xffa6adc8);
  static const Color mochaSurface1 = Color(0xff45475a);
  static const Color mochaSurface0 = Color(0xff313244);
  static const Color mochaBase = Color(0xff1e1e2e); // Background
  static const Color mochaMantle = Color(0xff181825); // Surface
  static const Color mochaCrust = Color(0xff11111b);
}

// Extension for easier alpha modification if needed later
extension ColorAlpha on Color {
  Color withValues({int? alpha}) {
    return withAlpha(alpha ?? this.alpha);
  }
}
