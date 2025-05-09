import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import '../screens/dictionary_detail_screen.dart' show DictionaryDetailScreen;
import 'confirm_delete_dialog.dart';
import 'edit_dictionary_dialog.dart';

class DictionaryItem extends StatelessWidget {
  final Dictionary dictionary;

  const DictionaryItem({required this.dictionary, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final currentDictionary = provider.dictionaries.firstWhere(
          (d) => d.name == dictionary.name,
          orElse: () => dictionary,
        );

        final IconData dictionaryIcon =
            currentDictionary.type == DictionaryType.sentence
                ? Icons.short_text
                : currentDictionary.type == DictionaryType.phrase
                    ? Icons.record_voice_over
                    : Icons.translate_outlined;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 80));

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DictionaryDetailScreen(
                      dictionary: currentDictionary,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 4.0,
                top: 12.0,
                bottom: 12.0,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    dictionaryIcon,
                    color: currentDictionary.color,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      currentDictionary.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'edit':
                          _editDictionary(context, currentDictionary);
                          break;
                        case 'delete':
                          _deleteDictionary(context, currentDictionary);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(AppLocalizations.of(context)!.edit),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text(AppLocalizations.of(context)!.delete),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context)!.options,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteDictionary(
    BuildContext context,
    Dictionary currentDictionary,
  ) async {
    final dictionaryProvider = Provider.of<DictionaryProvider>(
      context,
      listen: false,
    );
    final originalName = currentDictionary.name;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return ConfirmDeleteDialog(dictionaryName: originalName);
      },
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await dictionaryProvider.deleteDictionary(originalName);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!
                    .dictionaryDeletedWithName(originalName),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error deleting dictionary in DictionaryItem: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.errorDeletingDictionary(originalName)}: ${dictionaryProvider.error ?? e.toString()}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          dictionaryProvider.clearError();
        }
      }
    }
  }

  Future<void> _editDictionary(
    BuildContext context,
    Dictionary currentDictionary,
  ) async {
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    provider.clearError();

    final result = await showDialog<EditDictionaryDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final dialogProvider = Provider.of<DictionaryProvider>(
          dialogContext,
          listen: false,
        );
        final latestDictionary = dialogProvider.dictionaries.firstWhere(
          (d) => d.name == currentDictionary.name,
          orElse: () => currentDictionary,
        );

        return EditDictionaryDialog(
          initialDictionary: latestDictionary,
          onDictionaryUpdated: (oldName, newName, newColor) async {
            return await dialogProvider.updateDictionaryProperties(
              oldName,
              newName,
              newColor,
            );
          },
          dictionaryExists: (name) async {
            return await dialogProvider.dictionaryExists(name);
          },
        );
      },
    );

    if (!context.mounted || result == null) return;

    final potentiallyUpdatedDictionary = provider.dictionaries.firstWhere(
      (d) =>
          d.name == currentDictionary.name ||
          (result.status == EditDictionaryDialogStatus.saved),
      orElse: () => currentDictionary,
    );

    switch (result.status) {
      case EditDictionaryDialogStatus.saved:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!
                  .dictionaryUpdated(potentiallyUpdatedDictionary.name),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case EditDictionaryDialogStatus.cancelled:
        break;
      case EditDictionaryDialogStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToUpdateDictionary,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
}
