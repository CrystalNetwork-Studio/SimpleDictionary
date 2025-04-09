import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';
import 'package:simpledictionary/screens/add_word_screen.dart';
import 'package:simpledictionary/widgets/edit_word_dialog.dart';

enum SortOrder { alphabetical, lastAdded }

class DictionaryDetailScreen extends StatefulWidget {
  final Dictionary dictionary;

  const DictionaryDetailScreen({required this.dictionary, super.key});

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  SortOrder _sortOrder = SortOrder.alphabetical;

  List<Word> _getSortedWords(Dictionary dictionary, SortOrder sortOrder) {
    List<Word> words = List.from(dictionary.words);
    if (sortOrder == SortOrder.alphabetical) {
      words.sort(
        (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
      );
    }
    return words;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Consumer<DictionaryProvider>(
      builder: (context, provider, child) {
        Dictionary? currentDict;
        try {
          currentDict = provider.dictionaries.firstWhere(
            (d) => d.name == widget.dictionary.name,
          );
        } catch (e) {
          debugPrint(
            "Dictionary '${widget.dictionary.name}' not found in provider. It might have been deleted.",
          );
          return Scaffold(
            appBar: AppBar(title: Text(widget.dictionary.name)),
            body: Center(
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
                    localization.dictionaryNotFound,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.dictionaryMightBeDeleted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localization.goBack),
                  ),
                ],
              ),
            ),
          );
        }

        final List<Word> sortedWords = _getSortedWords(currentDict, _sortOrder);
        final DictionaryType dictionaryType = currentDict.type;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentDict.name),
            actions: [
              IconButton(
                icon: Icon(
                  _sortOrder == SortOrder.alphabetical
                      ? Icons.sort_by_alpha
                      : Icons.access_time,
                ),
                onPressed: () {
                  setState(() {
                    _sortOrder =
                        _sortOrder == SortOrder.alphabetical
                            ? SortOrder.lastAdded
                            : SortOrder.alphabetical;
                  });
                },
                tooltip:
                    _sortOrder == SortOrder.alphabetical
                        ? localization.sortByLastAdded
                        : localization.sortByAlphabetical,
              ),
            ],
          ),
          body:
              sortedWords.isEmpty
                  ? Center(
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
                          localization.dictionaryEmpty,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localization.addWordsByPressingButton,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                  : WordsList(
                    currentDict: currentDict,
                    words: sortedWords,
                    onEditWord: (context, dictionary, word) {
                      _showEditWordDialog(context, dictionary, word);
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddWordScreen(
                        dictionaryType: dictionaryType,
                        onWordAdded: (newWord) async {
                          final dictProvider = Provider.of<DictionaryProvider>(
                            context,
                            listen: false,
                          );
                          dictProvider.clearError();
                          return await dictProvider.addWordToDictionary(
                            currentDict!.name,
                            newWord,
                            context: context,
                          );
                        },
                      ),
                ),
              );
            },
            tooltip: localization.addNewWord,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showEditWordDialog(
    BuildContext context,
    Dictionary currentDictionary,
    Word word,
  ) {
    final localization = AppLocalizations.of(context)!;
    final provider = Provider.of<DictionaryProvider>(context, listen: false);

    final actualIndex = currentDictionary.words.indexWhere(
      (w) => w.term == word.term && w.translation == word.translation,
    );

    if (actualIndex == -1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.failedToFindWordForEdit),
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
        return EditWordDialog(
          initialWord: word,
          dictionaryName: currentDictionary.name,
          wordIndex: actualIndex,
          dictionaryType: currentDictionary.type,
          onWordUpdated: (indexFromDialog, updatedWord) async {
            provider.clearError();
            bool success = await provider.updateWordInDictionary(
              currentDictionary.name,
              indexFromDialog,
              updatedWord,
              context: dialogContext,
            );
            return success;
          },
          onWordDeleted: (indexFromDialog) async {
            provider.clearError();
            final wordTermToDelete =
                currentDictionary.words[indexFromDialog].term;
            bool success = await provider.removeWordFromDictionary(
              currentDictionary.name,
              indexFromDialog,
              context: dialogContext,
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
            SnackBar(
              content: Text(localization.wordUpdatedSuccessfully),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case EditWordDialogStatus.deleted:
          if (result.deletedWordTerm != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localization.wordDeletedWithName(result.deletedWordTerm!, ''),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.wordDeleted),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
        case EditWordDialogStatus.cancelled:
          break;
        case EditWordDialogStatus.error:
          break;
      }
    });
  }
}

class WordsList extends StatelessWidget {
  final Dictionary currentDict;
  final List<Word> words;
  final void Function(BuildContext context, Dictionary dictionary, Word word)
  onEditWord;

  const WordsList({
    required this.currentDict,
    required this.words,
    required this.onEditWord,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final wordKey = ValueKey(
          '${currentDict.name}_${word.term}_${word.translation}',
        );
        return WordCard(
          key: wordKey,
          word: word,
          dictionaryType: currentDict.type,
          onEdit: () => onEditWord(context, currentDict, word),
        );
      },
    );
  }
}

class WordCard extends StatelessWidget {
  final Word word;
  final DictionaryType dictionaryType;
  final Function() onEdit;

  const WordCard({
    required this.word,
    required this.dictionaryType,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    TextAlign alignment;
    CrossAxisAlignment crossAxisAlignmentItemAlignment;
    Alignment rowChildAlignment;
    bool descriptionVisible = false;

    switch (dictionaryType) {
      case DictionaryType.word:
        alignment = TextAlign.center;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.center;
        rowChildAlignment = Alignment.center;
        descriptionVisible =
            word.description != null && word.description!.isNotEmpty;
        break;
      case DictionaryType.phrase:
      case DictionaryType.sentence:
        alignment = TextAlign.start;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.start;
        rowChildAlignment = Alignment.centerLeft;
        descriptionVisible = false;
        break;
    }
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onLongPressStart: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.holdToEdit),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onLongPress: () {
          Future.delayed(const Duration(seconds: 2), () {
            onEdit();
          });
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: crossAxisAlignmentItemAlignment,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: rowChildAlignment,
                        child: Text(
                          word.term,
                          textAlign: alignment,
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: null,
                          softWrap: true,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: VerticalDivider(thickness: 1, width: 1),
                    ),
                    Expanded(
                      child: Align(
                        alignment: rowChildAlignment,
                        child: Text(
                          word.translation,
                          textAlign: alignment,
                          style: textTheme.titleMedium,
                          maxLines: null,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (descriptionVisible) ...[
                const Divider(height: 20, thickness: 0.5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.description!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
