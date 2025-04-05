import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: <Widget>[
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.appearance,
              ),
              _buildThemeSetting(context, settingsProvider),
              const Divider(),
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.dataManagement,
              ),
              _buildImportExportTile(context),
              const Divider(),
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.language,
              ),
              _buildLanguageSetting(context, settingsProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImportExportTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.import_export),
      title: Text(AppLocalizations.of(context)!.importExportDictionaries),
      onTap: () {
        // TODO: Implement Import/Export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.oopsImportExportNotReady,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSetting(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(_localeToString(provider.locale, context)),
      onTap: () async {
        final selectedLocale = await showDialog<Locale>(
          context: context,
          builder: (BuildContext dialogContext) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(dialogContext)!.language),
              children: <Widget>[
                RadioListTile<Locale>(
                  title: Text(
                    AppLocalizations.of(dialogContext)!.languageEnglish,
                  ),
                  value: const Locale('en'),
                  groupValue: provider.locale,
                  onChanged: (Locale? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<Locale>(
                  title: Text(
                    AppLocalizations.of(dialogContext)!.languageUkrainian,
                  ),
                  value: const Locale('uk'),
                  groupValue: provider.locale,
                  onChanged: (Locale? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<Locale>(
                  title: Text(
                    AppLocalizations.of(dialogContext)!.systemDefault,
                  ),
                  value: const Locale('system'),
                  groupValue: provider.locale,
                  onChanged: (Locale? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          },
        );

        if (selectedLocale != null) {
          final localContext = context;
          if (!localContext.mounted) return;
          context.read<SettingsProvider>().setLocale(selectedLocale);
        }
      },
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
      leading: const Icon(Icons.brightness_6),
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Text(_themeModeToString(provider.themeMode, context)),
      onTap: () async {
        final selectedTheme = await showDialog<ThemeMode>(
          context: context,
          builder: (BuildContext dialogContext) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(dialogContext)!.theme),
              children: <Widget>[
                RadioListTile<ThemeMode>(
                  title: Text(AppLocalizations.of(dialogContext)!.light),
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(AppLocalizations.of(dialogContext)!.dark),
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) {
                    Navigator.pop(dialogContext, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    AppLocalizations.of(dialogContext)!.systemDefault,
                  ),
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
          final localContext = context;
          if (!localContext.mounted) return;
          localContext.read<SettingsProvider>().setThemeMode(selectedTheme);
        }
      },
    );
  }

  String _localeToString(Locale? locale, BuildContext context) {
    if (locale == null) {
      return AppLocalizations.of(context)!.systemDefault;
    }
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.languageEnglish;
      case 'uk':
        return AppLocalizations.of(context)!.languageUkrainian;
      default:
        return 'System Default';
    }
  }

  String _themeModeToString(ThemeMode mode, BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return AppLocalizations.of(context)!.light;
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.dark;
      case ThemeMode.system:
      // ignore: unreachable_switch_default
      default:
        return AppLocalizations.of(context)!.systemDefault;
    }
  }
}
