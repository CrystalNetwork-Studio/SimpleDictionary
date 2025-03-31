import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import 'confirm_delete_dialog.dart';

class DictionaryItem extends StatelessWidget {
  final Dictionary dictionary;

  const DictionaryItem({required this.dictionary, super.key});

  @override
  Widget build(BuildContext context) {
    final dictionaryProvider = Provider.of<DictionaryProvider>(
      context,
      listen: false,
    );
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      // Use settings from CardTheme
      child: InkWell(
        // Make card clickable
        onTap: () {
          // TODO: Navigate to dictionary details screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Перегляд ${dictionary.name} ще не реалізовано.'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.folder_outlined, // KMM used Filled.Folder
                color:
                    textTheme
                        .bodyLarge
                        ?.color, // Use default text color for icon
              ),
              const SizedBox(width: 16),
              Expanded(
                // Make text take available space
                child: Text(
                  dictionary.name,
                  style: textTheme.titleMedium, // Equivalent to subtitle1
                  overflow:
                      TextOverflow.ellipsis, // Prevent long names overflowing
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline, // Use outlined version
                  color: colorScheme.error,
                ),
                tooltip: 'Видалити ${dictionary.name}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return ConfirmDeleteDialog(
                        dictionaryName: dictionary.name,
                        onConfirm: () {
                          // Call provider to delete
                          dictionaryProvider.deleteDictionary(dictionary);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
