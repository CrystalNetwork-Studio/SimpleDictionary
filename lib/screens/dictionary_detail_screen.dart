import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import 'add_word_screen.dart';

class DictionaryDetailScreen extends StatelessWidget {
  final Dictionary dictionary;

  const DictionaryDetailScreen({
    required this.dictionary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dictionary.name),
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          // Find the current version of this dictionary
          final currentDict = provider.dictionaries.firstWhere(
            (d) => d.name == dictionary.name,
            orElse: () => dictionary,
          );

          if (currentDict.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Словник порожній',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Додайте слова, натиснувши кнопку "+"\nвнизу екрана',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentDict.words.length,
            itemBuilder: (context, index) {
              final word = currentDict.words[index];
              return Dismissible(
                key: ValueKey('${word.term}_${index}'),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Підтвердити видалення'),
                        content: Text(
                            'Ви впевнені, що хочете видалити слово "${word.term}"?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Скасувати'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Видалити'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  // Create a copy of the words list without the deleted word
                  final updatedWords = List<Word>.from(currentDict.words)
                    ..removeAt(index);
                  
                  // Create an updated dictionary
                  final updatedDict = currentDict.copyWith(words: updatedWords);
                  
                  // Update the dictionary in the provider
                  provider.updateDictionary(updatedDict);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Слово "${word.term}" видалено'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.term,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        Text(
                          'Переклад: ${word.translation}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (word.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Опис: ${word.description}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWordScreen(
                onWordAdded: (word) {
                  Provider.of<DictionaryProvider>(context, listen: false)
                      .addWordToDictionary(dictionary.name, word);
                },
              ),
            ),
          );
        },
        tooltip: 'Додати слово',
        child: const Icon(Icons.add),
      ),
    );
  }
}