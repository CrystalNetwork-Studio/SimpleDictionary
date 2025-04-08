import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';

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
                children: [
                  _buildImportTile(context),
                  _buildExportTile(context),
                ],
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

  Widget _buildExportTile(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.upload_file_outlined,
        size: 24,
        color: theme.iconTheme.color,
      ),
      title: Text(
        localizations.exportDictionary,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
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
        await _exportDictionary(context);
      },
    );
  }

  Widget _buildImportTile(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.download_for_offline_outlined,
        size: 24,
        color: theme.iconTheme.color,
      ),
      title: Text(
        localizations.importDictionary,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      dense: true,
      onTap: () async {
        await _importDictionary(context);
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
        final currentLocale = context.read<SettingsProvider>().locale;

        final selectedLocale = await showDialog<Locale?>(
          context: context,
          builder: (BuildContext dialogContext) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(dialogContext)!.language),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              children: <Widget>[
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.languageEnglish,
                  value: const Locale('en'),
                  groupValue: currentLocale,
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.languageUkrainian,
                  value: const Locale('uk'),
                  groupValue: currentLocale,
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
                _buildRadioListTile<Locale?>(
                  context: dialogContext,
                  title: AppLocalizations.of(dialogContext)!.systemDefault,
                  value: null,
                  groupValue: currentLocale,
                  onChanged:
                      (Locale? value) => Navigator.pop(dialogContext, value),
                ),
              ],
            );
          },
        );

        if (!context.mounted) return;

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

        if (!context.mounted) return;
        if (selectedTheme != null && selectedTheme != provider.themeMode) {
          context.read<SettingsProvider>().setThemeMode(selectedTheme);
        }
      },
    );
  }

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

  Future<void> _exportDictionary(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    Provider.of<DictionaryProvider>(context, listen: false);

    final dictionaryToExport = await _showExportSelectionDialog(context);
    if (dictionaryToExport == null || !context.mounted) return;

    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        if (context.mounted) {
          _showErrorSnackBar(context, localizations.permissionDenied);
        }
        return;
      }
    }

    try {
      final jsonString = jsonEncode(dictionaryToExport.toJson());
      final Uint8List fileBytes = utf8.encode(jsonString);
      final String suggestedName = '${dictionaryToExport.name}.json';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: localizations.selectExportLocation,
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: fileBytes,
      );

      if (outputFile == null) {
        if (context.mounted) {
          _showSnackBar(context, localizations.filePickerOperationCancelled);
        }
        return;
      }

      if (context.mounted) {
        _showSnackBar(
          context,
          localizations.dictionaryExportedSuccess(
            dictionaryToExport.name,
            outputFile,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          localizations.dictionaryExportFailed(
            dictionaryToExport.name,
            e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _importDictionary(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);

    if (Platform.isAndroid) {
      if (await Permission.storage.status.isDenied) {
        final permissions = [
          Permission.storage,
          Permission.manageExternalStorage,
        ];

        final statuses = await permissions.request();
        final denied = statuses.values.any((status) => status.isDenied);

        if (denied) {
          if (context.mounted) {
            _showErrorSnackBar(context, localizations.permissionDenied);
          }
          return;
        }
      }
    } else if (Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          if (context.mounted) {
            _showErrorSnackBar(context, localizations.permissionDenied);
          }
          return;
        }
      }
    }

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: localizations.selectDictionaryFileToImport,
      );

      if (result == null || result.files.single.path == null) {
        if (context.mounted) {
          _showSnackBar(context, localizations.filePickerOperationCancelled);
        }
        return;
      }

      final String filePath = result.files.single.path!;
      provider.clearError();
      final Dictionary? importedDict = await provider.loadDictionaryForImport(
        filePath,
      );

      if (!context.mounted) return;

      if (importedDict == null) {
        _showErrorSnackBar(
          context,
          provider.error ?? localizations.invalidDictionaryFile,
        );
        return;
      }

      final bool exists = await provider.dictionaryExists(importedDict.name);
      Dictionary? finalDictToImport = importedDict;

      if (exists) {
        final conflictResult = await _showImportConflictDialog(
          context,
          importedDict.name,
        );
        if (conflictResult == null) return;

        if (conflictResult == _ImportConflictAction.rename) {
          final newName = await _showRenameDialog(context, importedDict.name);
          if (newName == null || newName.trim().isEmpty) return;
          if (await provider.dictionaryExists(newName)) {
            if (!context.mounted) return;
            _showErrorSnackBar(context, localizations.dictionaryAlreadyExists);
            return;
          }
          finalDictToImport = importedDict.copyWith(name: newName);
        }
      }

      provider.clearError();
      final success = await provider.importDictionary(finalDictToImport);

      if (!context.mounted) return;
      if (success) {
        _showSnackBar(
          context,
          localizations.dictionaryImportedSuccess(finalDictToImport.name),
        );
      } else {
        _showErrorSnackBar(
          context,
          localizations.dictionaryImportFailed(
            provider.error ?? 'Unknown error',
          ),
        );
      }
    } on FormatException catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          '${localizations.invalidDictionaryFile} (${e.message})',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          localizations.dictionaryImportFailed(e.toString()),
        );
      }
    }
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

  Future<Dictionary?> _showExportSelectionDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    final dictionaries = provider.dictionaries;

    return await showDialog<Dictionary?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.selectDictionaryToExport),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dictionaries.length,
              itemBuilder: (context, index) {
                final dict = dictionaries[index];
                return ListTile(
                  leading: Icon(Icons.book_outlined, color: dict.color),
                  title: Text(dict.name),
                  onTap: () => Navigator.of(dialogContext).pop(dict),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<_ImportConflictAction?> _showImportConflictDialog(
    BuildContext context,
    String dictionaryName,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    return await showDialog<_ImportConflictAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.importNameConflictTitle),
          content: Text(
            localizations.importNameConflictContent(dictionaryName),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(null),
            ),
            TextButton(
              child: Text(localizations.rename),
              onPressed:
                  () => Navigator.of(
                    dialogContext,
                  ).pop(_ImportConflictAction.rename),
            ),
            ElevatedButton(
              child: Text(localizations.overwrite),
              onPressed:
                  () => Navigator.of(
                    dialogContext,
                  ).pop(_ImportConflictAction.overwrite),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRenameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.rename),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: localizations.enterNewName,
                labelText: localizations.dictionaryName,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.dictionaryNameNotEmpty;
                }
                if (value.trim() == currentName) {
                  return 'Please enter a different name.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(null),
            ),
            ElevatedButton(
              child: Text(localizations.rename),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, isError: true);
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

enum _ImportConflictAction { overwrite, rename }
