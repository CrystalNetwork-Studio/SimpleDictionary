import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            children: <Widget>[
              _buildExpansionTile(
                context: context,
                title: localizations.appearance,
                leadingIcon: Icons.palette_outlined,
                children: [_buildThemeSetting(context, settingsProvider)],
              ),
              _buildExpansionTile(
                context: context,
                title: localizations.dataManagement,
                leadingIcon: Icons.storage_outlined,
                children: [_buildImportExportTile(context)],
              ),
              _buildExpansionTile(
                context: context,
                title: localizations.language,
                leadingIcon: Icons.language_outlined,
                children: [_buildLanguageSetting(context, settingsProvider)],
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper widget to build an ExpansionTile for a settings section
  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required IconData leadingIcon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ExpansionTile(
        leading: Icon(leadingIcon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        childrenPadding: const EdgeInsets.only(
          bottom: 8.0,
          left: 16.0,
          right: 16.0,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        children: children,
      ),
    );
  }

  Widget _buildImportExportTile(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.importExportDictionaries),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () {
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
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(_localeToString(provider.locale, context)),
      trailing: const Icon(Icons.arrow_drop_down, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        // Read the current locale before showing the dialog
        final currentLocale = context.read<SettingsProvider>().locale;

        final selectedLocale = await showDialog<Locale?>(
          context: context,
          builder: (BuildContext dialogContext) {
            // Use the provider instance passed to the builder for initial groupValue
            return SimpleDialog(
              title: Text(AppLocalizations.of(dialogContext)!.language),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              children: <Widget>[
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.languageEnglish,
                  value: const Locale('en'),
                  groupValue: currentLocale, // Use locale read before dialog
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.languageUkrainian,
                  value: const Locale('uk'),
                  groupValue: currentLocale, // Use locale read before dialog
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.systemDefault,
                  value: null, // Represents system default
                  groupValue: currentLocale, // Use locale read before dialog
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
              ],
            );
          },
        );

        // Check if widget is still mounted BEFORE using context
        if (!context.mounted) return;

        // Check if a selection was made and it's different from the locale before the dialog
        if (selectedLocale != currentLocale) {
          context.read<SettingsProvider>().setLocale(selectedLocale);
        }
      },
    );
  }

  Widget _buildThemeSetting(BuildContext context, SettingsProvider provider) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme),
      subtitle: Text(_themeModeToString(provider.themeMode, context)),
      trailing: const Icon(Icons.arrow_drop_down, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        final selectedTheme = await showDialog<ThemeMode>(
          context: context,
          builder: (BuildContext dialogContext) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(dialogContext)!.theme),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              children: <Widget>[
                _buildRadioListTile<ThemeMode>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.light,
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged:
                      (ThemeMode? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<ThemeMode>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.dark,
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged:
                      (ThemeMode? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<ThemeMode>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.systemDefault,
                  value: ThemeMode.system,
                  groupValue: provider.themeMode,
                  onChanged:
                      (ThemeMode? value) => Navigator.pop(dialogContext, value),
                ),
              ],
            );
          },
        );

        // Check if the widget is still mounted
        if (!context.mounted) return;
        if (selectedTheme != null && selectedTheme != provider.themeMode) {
          context.read<SettingsProvider>().setThemeMode(selectedTheme);
        }
      },
    );
  }

  // Helper for creating styled RadioListTile instances
  Widget _buildRadioListTile<T>({
    required BuildContext context,
    required String title,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
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
        return AppLocalizations.of(context)!.systemDefault;
    }
  }

  String _themeModeToString(ThemeMode mode, BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return AppLocalizations.of(context)!.light;
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.dark;
      case ThemeMode.system:
        return AppLocalizations.of(context)!.systemDefault;
    }
  }
}
