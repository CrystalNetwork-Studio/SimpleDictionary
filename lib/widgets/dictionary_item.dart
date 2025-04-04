import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import '../screens/dictionary_detail_screen.dart';
import 'confirm_delete_dialog.dart';
import 'edit_dictionary_dialog.dart';

class DictionaryItem extends StatelessWidget {
  final Dictionary dictionary;

  const DictionaryItem({required this.dictionary, super.key});

  Future<void> _editDictionary(BuildContext context) async {
    final provider = Provider.of<DictionaryProvider>(context, listen: false);
    provider.clearError();

    final result = await showDialog<EditDictionaryDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dialogProvider = Provider.of<DictionaryProvider>(
          dialogContext,
          listen: false,
        );
        return EditDictionaryDialog(
          initialDictionary: dictionary,
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

    switch (result.status) {
      case EditDictionaryDialogStatus.saved:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Словник "${_getUpdatedName(context, dictionary.name)}" оновлено.',
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
            content: const Text('Не вдалося оновити словник.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  String _getUpdatedName(BuildContext context, String originalName) {
    try {
      final currentDictionaries =
          Provider.of<DictionaryProvider>(context, listen: false).dictionaries;
      final updated = currentDictionaries.firstWhere(
        (d) =>
            d.color == dictionary.color &&
            d.words.length == dictionary.words.length,
        orElse: () => dictionary,
      );
      return updated.name;
    } catch (_) {
      return originalName;
    }
  }

  Future<void> _deleteDictionary(BuildContext context) async {
    final dictionaryProvider = Provider.of<DictionaryProvider>(
      context,
      listen: false,
    );
    final originalName = dictionary.name;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
              content: Text('Словник "$originalName" видалено.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        print("Error deleting dictionary in DictionaryItem: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Помилка видалення "$originalName": ${dictionaryProvider.error ?? e.toString()}',
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        final currentDictionary = provider.dictionaries.firstWhere(
          (d) => d.name == dictionary.name,
          orElse: () {
            final potentialMatch = provider.dictionaries.firstWhere(
              (d) =>
                  d.words.length == dictionary.words.length &&
                  d.color.value == dictionary.color.value,
              orElse: () => dictionary,
            );
            return potentialMatch;
          },
        );

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          DictionaryDetailScreen(dictionary: currentDictionary),
                ),
              );
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
                    Icons.translate_outlined,
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
                          _editDictionary(context);
                          break;
                        case 'delete':
                          _deleteDictionary(context);
                          break;
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Редагувати'),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Видалити'),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
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
                    tooltip: 'Опції',
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
}
