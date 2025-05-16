import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemChrome and SystemUiOverlayStyle
import 'package:flutter_localizations/flutter_localizations.dart'; // Localization delegates
import 'package:provider/provider.dart'; // For state management

import 'l10n/app_localizations.dart'; // Localization class
import 'providers/dictionary_provider.dart'; // Dictionary provider
import 'providers/settings_provider.dart'; // Settings provider
import 'screens/home_screen.dart'; // Main screen
import 'theme/app_theme.dart'; // App themes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static SystemUiOverlayStyle getAppSystemUIOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;

    return SystemUiOverlayStyle(
      statusBarColor: theme.colorScheme.surfaceContainerHighest,
      statusBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness:
          isLightTheme ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'My Dictionary',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,
          locale: settingsProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('uk', ''),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return supportedLocales.first;
            }
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          home: const HomeScreen(),
          builder: (context, child) {
            // Using a static method to update the style
            SystemChrome.setSystemUIOverlayStyle(
                getAppSystemUIOverlayStyle(context));

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
