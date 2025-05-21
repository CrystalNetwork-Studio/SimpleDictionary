import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';
import 'package:simpledictionary/utils/android_storage_helper.dart';

/// Enum for import conflict resolution actions
enum ImportConflictAction { overwrite, rename }

/// A helper widget for dictionary import and export operations
/// with special handling for Android 11+ storage restrictions
class ImportExportHelper {
  /// Exports a dictionary to a file
  static Future<void> exportDictionary(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Using context in provider is safe as it's obtained before the async gap.
    Provider.of<DictionaryProvider>(context, listen: false);

    // Show dictionary selection dialog
    final dictionary = await _showDictionarySelectionDialog(context);
    if (dictionary == null || !context.mounted) return;

    try {
      // Export dictionary using Storage Access Framework
      final filePath = await AndroidStorageHelper.saveDictionaryToExternalFile(
        dictionary: dictionary,
        suggestedFilename: '${dictionary.name}.json',
        dialogTitle: l10n.selectExportLocation,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(l10n.dictionaryExportedSuccess(dictionary.name, filePath)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("Export error: $e");

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(l10n.dictionaryExportFailed(dictionary.name, e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Imports a dictionary from a file
  static Future<void> importDictionary(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    void showMessage(String message, {bool isError = false}) {
      scaffoldMessenger.showSnackBar(
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

    try {
      // Pick dictionary file using Storage Access Framework (SAF)
      final FilePickerResult? result =
          await AndroidStorageHelper.pickDictionaryFile(
        dialogTitle: l10n.selectDictionaryFileToImport,
      );

      if (result == null || result.files.isEmpty) {
        showMessage(l10n.filePickerOperationCancelled);
        return;
      }

      final fileBytes = result.files.single.bytes;
      final String? filePath = result.files.single.path;
      final String fileName = result.files.single.name; // Corrected type

      debugPrint(
          "Selected file: $fileName, Path: ${filePath ?? 'No path'}, Bytes: ${fileBytes != null ? '${fileBytes.length} bytes' : 'No bytes'}");

      // Early validation
      if (filePath == null && fileBytes == null) {
        showMessage(l10n.permissionDenied, isError: true);
        if (!context.mounted) return;
        showAndroidStorageInfoDialog(context);
        return;
      }

      provider.clearError();
      Dictionary? importedDict;

      // Try bytes-based method first (most reliable for Android 11+)
      if (fileBytes != null && fileBytes.isNotEmpty) {
        try {
          importedDict =
              await AndroidStorageHelper.readDictionaryFromBytes(fileBytes);
          debugPrint("Successfully loaded dictionary from bytes");
        } catch (e) {
          debugPrint("Failed to load dictionary from bytes: $e");

          if (e is FormatException) {
            showMessage('${l10n.invalidDictionaryFile} (${e.message})',
                isError: true);
            return;
          }
        }
      }

      // Try path-based method as fallback
      if (importedDict == null && filePath != null) {
        try {
          debugPrint("Attempting path-based import: $filePath");

          if (AndroidStorageHelper.isContentUri(filePath)) {
            if (fileBytes == null) {
              showMessage(l10n.permissionDenied, isError: true);
              if (!context.mounted) return; // Added mounted check
              showAndroidStorageInfoDialog(context);
              return;
            }
            // If it's a content URI but we already got bytes, we don't need the path fallback.
            // If fileBytes was null, we would have returned already.
          } else {
            // Regular file path
            importedDict = await provider.loadDictionaryForImport(filePath);
          }
        } catch (e) {
          debugPrint("Path-based import failed: $e");
          showMessage(l10n.dictionaryImportFailed(e.toString()), isError: true);
          if (!context.mounted) return; // Added mounted check
          showAndroidStorageInfoDialog(context);
          return;
        }
      }

      if (importedDict == null) {
        showMessage(l10n.invalidDictionaryFile, isError: true);
        return;
      }

      // Handle name conflicts
      final bool exists = await provider.dictionaryExists(importedDict.name);
      Dictionary finalDictToImport =
          importedDict; // Make finalDictToImport non-nullable

      if (exists && context.mounted) {
        final conflictResult =
            await _showNameConflictDialog(context, importedDict.name);
        if (conflictResult == null) return;

        if (conflictResult == ImportConflictAction.rename && context.mounted) {
          final newName = await _showRenameDialog(context, importedDict.name);
          if (newName == null || newName.trim().isEmpty) return;

          if (await provider.dictionaryExists(newName)) {
            showMessage(l10n.dictionaryAlreadyExists, isError: true);
            return;
          }
          finalDictToImport = importedDict.copyWith(name: newName);
        }
      }

      // Import the dictionary
      // Check context.mounted again before using provider after potential await for dialogs
      if (!context.mounted) return;
      final success = await provider.importDictionary(finalDictToImport);

      if (!context.mounted) return;

      if (success) {
        showMessage(l10n.dictionaryImportedSuccess(finalDictToImport.name));
      } else {
        showMessage(
            l10n.dictionaryImportFailed(provider.error ?? 'Unknown error'),
            isError: true);
      }
    } catch (e) {
      debugPrint("Import error: $e");
      if (context.mounted) {
        showMessage(l10n.dictionaryImportFailed(e.toString()), isError: true);
      }
    }
  }

  /// Shows a dialog with instructions for Android storage access
  static void showAndroidStorageInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.importError),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The app couldn't access the selected file. This is common on Android 11+.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text("Try these solutions:"),
              const SizedBox(height: 8),
              _buildBulletPoint("Save the file to your Downloads folder first"),
              _buildBulletPoint("Use the device's built-in file manager"),
              _buildBulletPoint("Select a file from internal storage"),
              _buildBulletPoint(
                  "If using SD card, move file to internal storage"),
              const SizedBox(height: 12),
              const Text(
                "Note: On Android 13+, system security restrictions limit access to some storage locations.",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(l10n.import),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                importDictionary(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Helper UI methods

  /// Creates a bullet point widget for lists
  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  /// Shows a dialog for selecting a dictionary to export
  static Future<Dictionary?> _showDictionarySelectionDialog(
      BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Using context in provider is safe as it's obtained before the async gap.
    final provider = Provider.of<DictionaryProvider>(context, listen: false);

    if (provider.dictionaries.isEmpty) {
      // Using context here is safe as we are not inside an async gap yet.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noDictionariesToExport),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }

    // Using context in showDialog is safe. The builder function receives a new dialogContext.
    return await showDialog<Dictionary?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectDictionaryToExport),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.dictionaries.length,
              itemBuilder: (context, index) {
                final dict = provider.dictionaries[index];
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
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for handling name conflicts during import
  static Future<ImportConflictAction?> _showNameConflictDialog(
    BuildContext context,
    String dictionaryName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Using context in showDialog is safe. The builder function receives a new dialogContext.
    return await showDialog<ImportConflictAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.importNameConflictTitle),
          content: Text(l10n.importNameConflictContent(dictionaryName)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(null),
            ),
            TextButton(
              child: Text(l10n.rename),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(ImportConflictAction.rename),
            ),
            ElevatedButton(
              child: Text(l10n.overwrite),
              onPressed: () => Navigator.of(dialogContext)
                  .pop(ImportConflictAction.overwrite),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for renaming a dictionary during import
  static Future<String?> _showRenameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Using context in showDialog is safe. The builder function receives a new dialogContext.
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.rename),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.enterNewName,
                labelText: l10n.dictionaryName,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.dictionaryNameNotEmpty;
                }
                if (value.trim() == currentName) {
                  return 'Please enter a different name.';
                }

                // Check for invalid characters
                final RegExp invalidChars = RegExp(r'[\/\\:*?"<>|]');
                if (invalidChars.hasMatch(value)) {
                  return l10n.invalidFolderNameChars;
                }

                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(null),
            ),
            ElevatedButton(
              child: Text(l10n.rename),
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
}
