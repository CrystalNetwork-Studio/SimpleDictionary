import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import 'add_word_screen.dart';

class DictionaryDetailScreen extends StatefulWidget {
  final Dictionary dictionary;

  const DictionaryDetailScreen({required this.dictionary, super.key});

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dictionary.name)),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          // Find the current version of this dictionary
          final currentDict = provider.dictionaries.firstWhere(
            (d) => d.name == widget.dictionary.name,
            orElse: () => widget.dictionary,
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

          return WordsList(
            currentDict: currentDict,
            provider: provider,
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
                  Provider.of<DictionaryProvider>(
                    context,
                    listen: false,
                  ).addWordToDictionary(widget.dictionary.name, word);
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

class WordsList extends StatefulWidget {
  final Dictionary currentDict;
  final DictionaryProvider provider;

  const WordsList({
    required this.currentDict,
    required this.provider,
    super.key,
  });

  @override
  State<WordsList> createState() => _WordsListState();
}

class _WordsListState extends State<WordsList> {
  final List<GlobalKey<_WordCardState>> _wordKeys = [];

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  @override
  void didUpdateWidget(WordsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDict.words.length != _wordKeys.length) {
      _updateKeys();
    }
  }

  void _updateKeys() {
    _wordKeys.clear();
    for (int i = 0; i < widget.currentDict.words.length; i++) {
      _wordKeys.add(GlobalKey<_WordCardState>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.currentDict.words.length,
      itemBuilder: (context, index) {
        // Make sure we have enough keys
        if (index >= _wordKeys.length) {
          _updateKeys();
        }
        
        return WordCard(
          key: _wordKeys[index],
          word: widget.currentDict.words[index],
          index: index,
          dictionary: widget.currentDict,
          provider: widget.provider,
        );
      },
    );
  }
}

class WordCard extends StatefulWidget {
  final Word word;
  final int index;
  final Dictionary dictionary;
  final DictionaryProvider provider;

  const WordCard({
    required this.word,
    required this.index,
    required this.dictionary,
    required this.provider,
    super.key,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  // For tracking dismissal state
  bool _isConfirming = false;

  Future<bool> _confirmDeletion() async {
    if (_isConfirming) return false;
    
    _isConfirming = true;
    
    final bool shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Підтвердити видалення'),
          content: Text(
            'Ви впевнені, що хочете видалити слово "${widget.word.term}"?'
          ),
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
    ) ?? false;
    
    if (shouldDelete && context.mounted) {
      try {
        // Make sure the index is still valid
        if (widget.index >= 0 && widget.index < widget.dictionary.words.length) {
          // Create a copy of the words list without the deleted word
          final List<Word> updatedWords = List<Word>.from(widget.dictionary.words);
          updatedWords.removeAt(widget.index);
          
          // Create an updated dictionary
          final updatedDict = widget.dictionary.copyWith(words: updatedWords);
          
          // Update the dictionary in the provider
          await widget.provider.updateDictionary(updatedDict);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Слово "${widget.word.term}" видалено'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        print('Помилка при видаленні слова: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Помилка при видаленні слова'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _isConfirming = false;
        return false;
      }
    }
    
    _isConfirming = false;
    return shouldDelete;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${widget.word.term}_${widget.index}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      confirmDismiss: (_) => _confirmDeletion(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.word.term,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              Text(
                'Переклад: ${widget.word.translation}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (widget.word.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Опис: ${widget.word.description}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
