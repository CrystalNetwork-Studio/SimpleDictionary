import 'package:flutter/material.dart';

class AppTheme {
  // Base colors for light theme (Catppuccin Latte)
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: CatppuccinColors.latteBlue,
    brightness: Brightness.light,
    surface: CatppuccinColors.latteBase,
    surfaceContainerHighest: CatppuccinColors.latteMantle,
    onSurface: const Color(0xFF1A1B21),
    primary: CatppuccinColors.latteBlue,
    onPrimary: Colors.white,
    secondary: CatppuccinColors.latteMauve,
    onSecondary: Colors.white,
    tertiary: CatppuccinColors.latteSky,
    onTertiary: Colors.white,
    error: CatppuccinColors.latteRed,
    onError: Colors.white,
    surfaceContainerLow: CatppuccinColors.latteSurface0,
    onSurfaceVariant:
        const Color(0xFF4A4B52), // Теплий сірий для вторинного тексту
    outline: const Color(0xFFA6A8B5),
    outlineVariant: const Color(0xFFA6A8B5),
  );

  // Base colors for dark theme ( Catppuccin Mocha)
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: CatppuccinColors.mochaBlue,
    brightness: Brightness.dark,
    surface: CatppuccinColors.mochaBase,
    surfaceContainerHighest: CatppuccinColors.mochaMantle,
    onSurface: CatppuccinColors.mochaText,
    primary: CatppuccinColors.mochaBlue,
    onPrimary: CatppuccinColors.mochaCrust,
    secondary: CatppuccinColors.mochaMauve,
    onSecondary: CatppuccinColors.mochaCrust,
    tertiary: CatppuccinColors.mochaSky,
    onTertiary: CatppuccinColors.mochaCrust,
    error: CatppuccinColors.mochaRed,
    onError: CatppuccinColors.mochaCrust,
    surfaceContainerLow: CatppuccinColors.mochaSurface0,
    onSurfaceVariant: CatppuccinColors.mochaSubtext0,
    outline: CatppuccinColors.mochaSurface1,
    outlineVariant: CatppuccinColors.mochaSurface0,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    textTheme: _createTextTheme(
        _lightColorScheme.onSurface, _lightColorScheme.onSurfaceVariant),
    appBarTheme: AppBarTheme(
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightColorScheme.surfaceContainerHighest,
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontSize: 18,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _lightColorScheme.tertiary;
        }
        return _lightColorScheme.onSurfaceVariant.withOpacity(0.4);
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _lightColorScheme.tertiary,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _lightColorScheme.tertiary,
      selectionColor: _lightColorScheme.tertiary.withOpacity(0.3),
      selectionHandleColor: _lightColorScheme.tertiary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _lightColorScheme.primary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: _lightColorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _lightColorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outline,
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _lightColorScheme.onSurfaceVariant,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _lightColorScheme.surfaceContainerLow,
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _lightColorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      textStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 16,
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkColorScheme,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    textTheme: _createTextTheme(
        _darkColorScheme.onSurface, _darkColorScheme.onSurfaceVariant),
    appBarTheme: AppBarTheme(
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkColorScheme.surfaceContainerHighest,
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontSize: 18,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkColorScheme.tertiary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _darkColorScheme.tertiary;
        }
        return _darkColorScheme.onSurfaceVariant.withOpacity(0.4);
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _darkColorScheme.tertiary,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _darkColorScheme.tertiary,
      selectionColor: _darkColorScheme.tertiary.withOpacity(0.3),
      selectionHandleColor: _darkColorScheme.tertiary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.primary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: _darkColorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _darkColorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outlineVariant,
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _darkColorScheme.onSurfaceVariant,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkColorScheme.surfaceContainerLow,
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _darkColorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      textStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 16,
      ),
    ),
  );

  static TextTheme _createTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      displaySmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
      headlineSmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
      bodyLarge: TextStyle(fontSize: 18, color: primaryColor),
      bodyMedium: TextStyle(fontSize: 16, color: secondaryColor),
      bodySmall:
          TextStyle(fontSize: 14, color: secondaryColor.withOpacity(0.7)),
      labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColor),
      labelMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: secondaryColor),
      labelSmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: secondaryColor),
    );
  }
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
  static const Color mochaRed = Color(0xff8839ef);
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

// Extension for easier alpha modification if needed
extension ColorAlpha on Color {
  Color withValues({double? alpha}) {
    int alphaInt = (alpha ?? a.toDouble()).toInt();
    return withAlpha(alphaInt);
  }
}
