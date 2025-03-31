import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування')),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: <Widget>[
              _buildSectionHeader(context, 'Вигляд'),
              _buildThemeSetting(context, settingsProvider),
              const Divider(),
              _buildSectionHeader(context, 'Керування Даними'),
              _buildImportExportTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context, SettingsProvider provider) {
    return ListTile(
      leading: const Icon(Icons.brightness_6), // Icon for theme
      title: const Text('Тема'),
      subtitle: Text(_themeModeToString(provider.themeMode)),
      onTap: () async {
        final selectedTheme = await showDialog<ThemeMode>(
          context: context,
          builder: (BuildContext dialogContext) {
            return SimpleDialog(
              title: const Text('Вибрати тему'),
              children: <Widget>[
                RadioListTile<ThemeMode>(
                  title: const Text('Світла'),
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Темна'),
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Системна'),
                  value: ThemeMode.system,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          },
        );

        if (selectedTheme != null) {
          // Use read for calls outside build/builder methods
          context.read<SettingsProvider>().setThemeMode(selectedTheme);
        }
      },
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Світла';
      case ThemeMode.dark:
        return 'Темна';
      case ThemeMode.system:
      // ignore: unreachable_switch_default
      default:
        return 'За замовчуванням системи';
    }
  }

  Widget _buildImportExportTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.import_export),
      title: const Text('Імпорт / Експорт словників'),
      onTap: () {
        // TODO: Implement Import/Export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Функція Імпорту/Експорту ще не реалізована.'),
          ),
        );
      },
    );
  }
}
