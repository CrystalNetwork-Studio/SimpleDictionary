import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/import_export_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            children: [
              _SettingsExpansionTile(
                title: localizations.appearance,
                leadingIcon: Icons.palette_outlined,
                children: [
                  _ThemeSettingTile(provider: settingsProvider),
                ],
              ),
              _SettingsExpansionTile(
                title: localizations.dataManagement,
                leadingIcon: Icons.storage_outlined,
                children: [
                  const _ImportTile(),
                  const _ExportTile(),
                ],
              ),
              _SettingsExpansionTile(
                title: localizations.language,
                leadingIcon: Icons.language_outlined,
                children: [
                  _LanguageSettingTile(provider: settingsProvider),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsExpansionTile extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final List<Widget> children;

  const _SettingsExpansionTile({
    required this.title,
    required this.leadingIcon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use explicit black87 for icons and text for better contrast in light theme
    final iconColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : theme.iconTheme.color;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : theme.textTheme.titleMedium?.color;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ExpansionTile(
        leading: Icon(leadingIcon, color: iconColor),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        childrenPadding:
            const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        children: children,
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    final theme = Theme.of(context);
    final iconColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.iconTheme.color;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color;

    return ListTile(
      leading: Icon(Icons.upload_file_outlined, size: 24, color: iconColor),
      title: Text(localizations.exportDictionary,
          style: TextStyle(color: textColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        if (provider.dictionaries.isEmpty) {
          _showSnackBar(
            context,
            localizations.noDictionariesToExport,
            isError: true,
          );
          return;
        }
        await ImportExportHelper.exportDictionary(context);
      },
    );
  }
}

class _ImportTile extends StatelessWidget {
  const _ImportTile();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Use explicit black87 for icons and text for better contrast in light theme
    final iconColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.iconTheme.color;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color;

    return ListTile(
      leading:
          Icon(Icons.download_for_offline_outlined, size: 24, color: iconColor),
      title: Text(localizations.importDictionary,
          style: TextStyle(color: textColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        await ImportExportHelper.importDictionary(context);
      },
    );
  }
}

class _LanguageSettingTile extends StatelessWidget {
  final SettingsProvider provider;

  const _LanguageSettingTile({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use explicit black87 for text and black54 for subtitle in light theme
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color;
    final subtitleColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : theme.textTheme.bodySmall?.color;
    final iconColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.iconTheme.color;

    return ListTile(
      title: Text(AppLocalizations.of(context)!.language,
          style: TextStyle(color: textColor)),
      subtitle: Text(_localeToString(provider.locale, context),
          style: TextStyle(color: subtitleColor)),
      trailing: Icon(Icons.arrow_drop_down, size: 20, color: iconColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        final currentLocale = context.read<SettingsProvider>().locale;

        final selectedLocale = await showDialog<Locale?>(
          context: context,
          builder: (BuildContext dialogContext) {
            final localizations = AppLocalizations.of(dialogContext)!;
            return SimpleDialog(
              title: Text(localizations.language),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              children: [
                _RadioListTile<Locale?>(
                  title: localizations.languageEnglish,
                  value: const Locale('en'),
                  groupValue: currentLocale,
                  onChanged: (Locale? value) =>
                      Navigator.pop(dialogContext, value),
                ),
                _RadioListTile<Locale?>(
                  title: localizations.languageUkrainian,
                  value: const Locale('uk'),
                  groupValue: currentLocale,
                  onChanged: (Locale? value) =>
                      Navigator.pop(dialogContext, value),
                ),
                _RadioListTile<Locale?>(
                  title: localizations.systemDefault,
                  value: null,
                  groupValue: currentLocale,
                  onChanged: (Locale? value) =>
                      Navigator.pop(dialogContext, value),
                ),
              ],
            );
          },
        );

        if (!context.mounted) return;

        if ((selectedLocale != null && selectedLocale != currentLocale) ||
            (selectedLocale == null && currentLocale != null)) {
          context.read<SettingsProvider>().setLocale(selectedLocale);
        }
      },
    );
  }
}

class _ThemeSettingTile extends StatelessWidget {
  final SettingsProvider provider;

  const _ThemeSettingTile({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use explicit black87 for text and black54 for subtitle in light theme
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color;
    final subtitleColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : theme.textTheme.bodySmall?.color;
    final iconColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.iconTheme.color;

    return ListTile(
      title: Text(AppLocalizations.of(context)!.theme,
          style: TextStyle(color: textColor)),
      subtitle: Text(_themeModeToString(provider.themeMode, context),
          style: TextStyle(color: subtitleColor)),
      trailing: Icon(Icons.arrow_drop_down, size: 20, color: iconColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        final selectedTheme = await showDialog<ThemeMode>(
          context: context,
          builder: (BuildContext dialogContext) {
            final localizations = AppLocalizations.of(dialogContext)!;
            return SimpleDialog(
              title: Text(localizations.theme),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              children: [
                _RadioListTile<ThemeMode>(
                  title: localizations.light,
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) =>
                      Navigator.pop(dialogContext, value),
                ),
                _RadioListTile<ThemeMode>(
                  title: localizations.dark,
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) =>
                      Navigator.pop(dialogContext, value),
                ),
                _RadioListTile<ThemeMode>(
                  title: localizations.systemDefault,
                  value: ThemeMode.system,
                  groupValue: provider.themeMode,
                  onChanged: (ThemeMode? value) =>
                      Navigator.pop(dialogContext, value),
                ),
              ],
            );
          },
        );

        if (!context.mounted) return;
        if (selectedTheme != null && selectedTheme != provider.themeMode) {
          context.read<SettingsProvider>().setThemeMode(selectedTheme);
        }
      },
    );
  }
}

class _RadioListTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioListTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use explicit black87 for text in light theme
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color;

    return RadioListTile<T>(
      title: Text(title, style: TextStyle(color: textColor)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
    );
  }
}

String _localeToString(Locale? locale, BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  if (locale == null) {
    return localizations.systemDefault;
  }
  switch (locale.languageCode) {
    case 'en':
      return localizations.languageEnglish;
    case 'uk':
      return localizations.languageUkrainian;
    default:
      return localizations.systemDefault;
  }
}

void _showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: isError ? Colors.white : null),
      ),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

String _themeModeToString(ThemeMode mode, BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  switch (mode) {
    case ThemeMode.light:
      return localizations.light;
    case ThemeMode.dark:
      return localizations.dark;
    case ThemeMode.system:
      return localizations.systemDefault;
  }
}
