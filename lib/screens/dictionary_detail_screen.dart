import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';
import '../widgets/edit_word_dialog.dart';
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
          Dictionary? currentDictFromProvider;
          try {
            currentDictFromProvider = provider.dictionaries.firstWhere(
              (d) => d.name == widget.dictionary.name,
            );
          } catch (e) {
            print(
              "Dictionary '${widget.dictionary.name}' not found in provider. It might have been deleted.",
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Словник не знайдено',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Можливо, його було видалено.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final currentDict = currentDictFromProvider;

          if (currentDict.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Словник порожній',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Додайте слова, натиснувши кнопку "+"\nвнизу екрана',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return WordsList(currentDict: currentDict, provider: provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final targetDictionaryName = widget.dictionary.name;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddWordScreen(
                    onWordAdded: (word) async {
                      Provider.of<DictionaryProvider>(
                        context,
                        listen: false,
                      ).clearError();
                      return await Provider.of<DictionaryProvider>(
                        context,
                        listen: false,
                      ).addWordToDictionary(targetDictionaryName, word);
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

class WordsList extends StatelessWidget {
  final Dictionary currentDict;
  final DictionaryProvider provider;

  const WordsList({
    required this.currentDict,
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final words = currentDict.words;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final wordKey =
            '${currentDict.name}_${word.term}_${word.translation}_$index';
        return WordCard(
          key: ValueKey(wordKey),
          word: word,
          index: index,
          dictionaryName: currentDict.name,
          provider: provider,
        );
      },
    );
  }
}

class WordCard extends StatefulWidget {
  final Word word;
  final int index;
  final String dictionaryName;
  final DictionaryProvider provider;

  const WordCard({
    required this.word,
    required this.index,
    required this.dictionaryName,
    required this.provider,
    super.key,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  void _showEditWordDialog() {
    final currentDictionary = widget.provider.dictionaries.firstWhere(
      (d) => d.name == widget.dictionaryName,
      orElse:
          () =>
              widget.provider.dictionaries.first, // Fallback, ideally it exists
    );
    final actualIndex = currentDictionary.words.indexWhere(
      (w) =>
          w.term == widget.word.term &&
          w.translation == widget.word.translation &&
          w.description == widget.word.description,
    );

    if (actualIndex == -1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не вдалося знайти слово для редагування/видалення.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    showDialog<EditWordDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final provider = Provider.of<DictionaryProvider>(
          dialogContext,
          listen: false,
        );
        return EditWordDialog(
          initialWord: widget.word,
          dictionaryName: widget.dictionaryName,
          wordIndex: actualIndex,
          onWordUpdated: (indexFromDialog, updatedWord) async {
            provider.clearError();
            bool success = await provider.updateWordInDictionary(
              widget.dictionaryName,
              indexFromDialog,
              updatedWord,
            );
            return success;
          },
          onWordDeleted: (indexFromDialog) async {
            provider.clearError();
            final wordTermToDelete =
                provider
                    .dictionaries[provider.dictionaries.indexWhere(
                      (d) => d.name == widget.dictionaryName,
                    )]
                    .words[indexFromDialog]
                    .term;

            bool success = await provider.removeWordFromDictionary(
              widget.dictionaryName,
              indexFromDialog,
            );
            return success ? wordTermToDelete : null;
          },
        );
      },
    ).then((result) {
      if (!mounted || result == null) return;

      switch (result.status) {
        case EditWordDialogStatus.saved:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Слово успішно оновлено!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case EditWordDialogStatus.deleted:
          if (result.deletedWordTerm != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Слово "${result.deletedWordTerm}" видалено'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Слово видалено'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
        case EditWordDialogStatus.cancelled:
        case EditWordDialogStatus.error:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    const TextAlign alignment = TextAlign.center;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _showEditWordDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.word.term,
                          textAlign: alignment,
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: VerticalDivider(thickness: 1, width: 1),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.word.translation,
                          textAlign: alignment,
                          style: textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.word.description.isNotEmpty) ...[
                const Divider(height: 20, thickness: 0.5),
                Text(
                  widget.word.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
