import 'package:flutter/material.dart';

class AppTheme {
  // Base colors for light theme (Catppuccin Latte)
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: CatppuccinColors.latteBlue, // Using Blue as the primary seed
    brightness: Brightness.light,
    // Override specific colors for better Catppuccin Latte mapping
    surface: CatppuccinColors.latteBase,
    surfaceContainerHighest: CatppuccinColors.latteMantle,
    onSurface: Colors.white, // White text
    primary: CatppuccinColors.latteBlue,
    onPrimary: Colors.white, // White text
    secondary: CatppuccinColors.latteMauve, // Using Mauve as secondary
    onSecondary: Colors.white, // White text
    tertiary: CatppuccinColors.latteSky, // Using Sky as tertiary accent
    onTertiary: Colors.white, // White text
    error: CatppuccinColors.latteRed,
    onError: Colors.white, // White text
    surfaceContainerLow:
        CatppuccinColors.latteSurface0, // Use for card/dialog backgrounds etc.
    onSurfaceVariant: Colors.white, // White text
    outline: Colors.white, // White for contrast
    outlineVariant: Colors.white, // White for contrast
  );

  // Base colors for dark theme (Catppuccin Mocha)
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: CatppuccinColors.mochaBlue, // Using Blue as the primary seed
    brightness: Brightness.dark,
    // Override specific colors for better Catppuccin Mocha mapping
    surface: CatppuccinColors.mochaBase,
    surfaceContainerHighest:
        CatppuccinColors.mochaMantle, // Use for AppBars, Cards, Dialogs
    onSurface: CatppuccinColors.mochaText,
    primary: CatppuccinColors.mochaBlue,
    onPrimary: CatppuccinColors.mochaCrust, // High contrast text on primary
    secondary: CatppuccinColors.mochaMauve, // Using Mauve as secondary
    onSecondary: CatppuccinColors.mochaCrust, // High contrast text on secondary
    tertiary: CatppuccinColors.mochaSky, // Using Sky as tertiary accent
    onTertiary: CatppuccinColors.mochaCrust, // High contrast text on tertiary
    error: CatppuccinColors.mochaRed,
    onError: CatppuccinColors.mochaCrust,
    surfaceContainerLow: CatppuccinColors
        .mochaSurface0, // Use for input fields, chip backgrounds
    onSurfaceVariant:
        CatppuccinColors.mochaSubtext0, // Text on surface variants
    outline: CatppuccinColors.mochaSurface1, // Borders
    outlineVariant: CatppuccinColors.mochaSurface0, // Subtle borders/dividers
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white, // White text
      elevation: 0, // Catppuccin often uses flat designs
      surfaceTintColor: Colors.transparent, // Prevent M3 tinting
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary, // Blue
      foregroundColor: Colors.white, // White text
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightColorScheme.surface, // Mantle
      titleTextStyle: TextStyle(
        color: Colors.white, // White text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: Colors.white, // White text
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, // White text
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary, // Blue
        foregroundColor: Colors.white, // White text
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    // Add switch theme for tertiary color
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightColorScheme.tertiary; // Sky for selected switch
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightColorScheme.tertiary
              .withValues(alpha: 0.5 * 255.0); // Transparent Sky for track
        }
        return null;
      }),
    ),
    // Add progress indicator theme for tertiary color
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _lightColorScheme.tertiary, // Sky for progress indicators
    ),
    // Add text selection theme for tertiary color
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _lightColorScheme.tertiary, // Sky for cursor
      selectionColor: _lightColorScheme.tertiary
          .withValues(alpha: 0.3 * 255.0), // Transparent Sky for selection
      selectionHandleColor:
          _lightColorScheme.tertiary, // Sky for selection handles
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest, // Surface0
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white, // White border
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: Colors.white, // White text
      ), // Subtext0
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.7), // White with opacity
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
      iconColor: Colors.white, // White
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent, // Make list tiles transparent on Latte
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white, // White
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white, // White
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _lightColorScheme.surface, // Surface0
      contentTextStyle: TextStyle(
        color: Colors.white, // White
      ), // Subtext0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4, // Slight elevation to distinguish
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _lightColorScheme.surface, // Mantle
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      textStyle: TextStyle(color: Colors.white), // White
    ),
  );

  // Dark Theme (Mocha)
  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkColorScheme.surface, // Base
    appBarTheme: AppBarTheme(
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
        foregroundColor:
            CatppuccinColors.mochaSapphire, // Sapphire for text buttons
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
    // Add switch theme for tertiary color
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.tertiary; // Sky for selected switch
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.tertiary
              .withValues(alpha: 0.5 * 255.0); // Transparent Sky for track
        }
        return null;
      }),
    ),
    // Add progress indicator theme for tertiary color
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _darkColorScheme.tertiary, // Sky for progress indicators
    ),
    // Add text selection theme for tertiary color
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _darkColorScheme.tertiary, // Sky for cursor
      selectionColor: _darkColorScheme.tertiary
          .withValues(alpha: 0.3 * 255.0), // Transparent Sky for selection
      selectionHandleColor:
          _darkColorScheme.tertiary, // Sky for selection handles
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerHighest, // Surface0
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CatppuccinColors.mochaSapphire, // Sapphire for focused borders
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
      ), // Subtext0
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant.withValues(alpha: 0.7 * 255.0),
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
      backgroundColor: _darkColorScheme.surfaceContainerHighest, // Surface0
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
class CatppuccinColors {
  // Latte
  static const Color latteMauve = Color(0xff8839ef);
  static const Color latteRed = Color(0xffd20f39);
  static const Color latteBlue = Color(0xff1e66f5); // Primary accent
  static const Color latteSky = Color(0xff04a5e5); // Lighter blue shade
  static const Color latteSapphire = Color(0xff209fb5); // Deeper blue shade
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
  static const Color mochaSky = Color(0xff89dceb); // Lighter blue shade
  static const Color mochaSapphire = Color(0xff74c7ec); // Deeper blue shade
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
  Color withValues({double? alpha}) {
    int alphaInt = (alpha ?? a.toDouble()).toInt();
    return withAlpha(alphaInt);
  }
}
