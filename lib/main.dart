import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Потрібно для SystemChrome та SystemUiOverlayStyle
import 'package:flutter_localizations/flutter_localizations.dart'; // Делегати локалізації
import 'package:provider/provider.dart'; // Для керування станом (State Management)

import 'l10n/app_localizations.dart'; // Клас для локалізації
import 'providers/dictionary_provider.dart'; // Провайдер словника
import 'providers/settings_provider.dart'; // Провайдер налаштувань
import 'screens/home_screen.dart'; // Головний екран
import 'theme/app_theme.dart'; // Теми додатку

Future<void> main() async {
  // Переконуємося, що Flutter ініціалізовано перед використанням плагінів або Platform Channels
  // Це обов'язково, якщо main є async або якщо ви викликаєте нативний код перед runApp
  WidgetsFlutterBinding.ensureInitialized();

  // --- Місце для потенційної асинхронної ініціалізації ---
  // Наприклад, завантаження налаштувань з SharedPreferences перед запуском:
  // final settingsProvider = SettingsProvider();
  // await settingsProvider.loadSettings(); // Потрібно реалізувати цей метод у SettingsProvider
  // Потім передати цей екземпляр через ChangeNotifierProvider.value замість .create
  // --- Кінець потенційної асинхронної ініціалізації ---

  // Можна встановити бажану орієнтацію екрану тут, якщо потрібно:
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);

  runApp(
    // MultiProvider дозволяє надати декілька провайдерів дереву віджетів
    MultiProvider(
      providers: [
        // ChangeNotifierProvider.create створює екземпляр провайдера "ліниво" (при першому запиті)
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Якщо використовували попередньо ініціалізований провайдер:
        // ChangeNotifierProvider.value(value: settingsProvider),
      ],
      // Використовуємо const MyApp для невеликої оптимізації,
      // оскільки сам віджет MyApp не змінюється.
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Конструктор з const для оптимізації
  const MyApp({super.key});

  // Приватний метод для інкапсуляції логіки оновлення стилю системних оверлеїв
  void _updateSystemUIOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.appBarTheme.backgroundColor, // Match AppBar color
      statusBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          // --- Метадані додатку ---
          title: 'My Dictionary', // Назва додатку, яка відображається в системі

          // --- Теми ---
          theme: AppTheme.lightTheme, // Світла тема додатку
          darkTheme: AppTheme.darkTheme, // Темна тема додатку
          // Визначає, яку тему використовувати (світлу, темну або системну)
          // Значення береться з SettingsProvider
          themeMode: settingsProvider.themeMode,

          // --- Локалізація ---
          // Встановлює поточну локаль (мову та регіон) додатку
          locale: settingsProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // Англійська
            Locale('uk', ''), // Українська
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return supportedLocales.first;
            }
            // Шукаємо підтримувану локаль, яка відповідає мові пристрою
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                // Знайдено! Повертаємо її.
                // Можна також перевіряти scriptCode або countryCode, якщо потрібно.
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          // --- Навігація ---
          home: const HomeScreen(),

          // --- Builder ---
          builder: (context, child) {
            _updateSystemUIOverlayStyle(context);

            return MediaQuery(
              // Створюємо копію даних MediaQuery з поточного контексту,
              // але змінюємо лише параметр textScaler.
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              // child! - це віджет, що представляє поточний екран/навігатор,
              // згенерований MaterialApp. Використовуємо `!`, бо впевнені, що child не буде null.
              child: child!,
            );
          },

          // --- Прапорці для налагодження (необов'язково) ---
          // Приховує банер "Debug" у верхньому правому куті екрану
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
