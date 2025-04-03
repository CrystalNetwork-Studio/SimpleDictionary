import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import '../screens/dictionary_detail_screen.dart';
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DictionaryDetailScreen(
                dictionary: dictionary,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.folder_outlined, color: textTheme.bodyLarge?.color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  dictionary.name,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
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
