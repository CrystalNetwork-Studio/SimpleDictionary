import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'providers/dictionary_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DictionaryProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Builder(
            builder: (context) {
              return MaterialApp(
                title: 'My Dictionary',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settingsProvider.themeMode,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('uk'), // Ukrainian
                ],
                locale: settingsProvider.locale,
                localeResolutionCallback: (locale, supportedLocales) {
                  if (locale == null) return const Locale('en');
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                  return const Locale('en');
                },
                home: const HomeScreen(),
                builder: (context, child) {
                  // Apply system UI overlay style dynamically based on theme
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;

                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor:
                        Colors.transparent, // Keep status bar transparent
                    statusBarIconBrightness:
                        isDark ? Brightness.light : Brightness.dark,
                    // Use scaffold background for nav bar to match screen background
                    systemNavigationBarColor: theme.scaffoldBackgroundColor,
                    // Set nav bar icons based on theme brightness
                    systemNavigationBarIconBrightness:
                        isDark ? Brightness.light : Brightness.dark,
                  ));

                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
