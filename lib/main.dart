// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/settings_provider.dart'; // Import SettingsProvider
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Ensure WidgetsBinding is initialized for SharedPreferences etc.
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
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(),
        ), // Add SettingsProvider
      ],
      child: Consumer<SettingsProvider>(
        // Consumer to rebuild MaterialApp on theme change
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Simple Dictionary',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // Use themeMode from SettingsProvider
            themeMode: settingsProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
