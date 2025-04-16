import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';
import 'package:simpledictionary/screens/add_word_screen.dart';

import 'edit_word_screen.dart';

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
    switch (sortOrder) {
      case SortOrder.alphabetical:
        words.sort(
          (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
        );
        break;
      case SortOrder.lastAdded:
        words = words.reversed.toList();
        break;
    }
    return words;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Consumer<DictionaryProvider>(
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localization.dictionaryMightBeDeleted,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(localization.goBack),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final List<Word> sortedWords = _getSortedWords(
            currentDict,
            _sortOrder,
          );
          final DictionaryType dictionaryType = currentDict.type;

          return Scaffold(
            appBar: AppBar(
              title: Text(currentDict.name),
              actions: [
                IconButton(
                  icon: Icon(
                    _sortOrder == SortOrder.alphabetical
                        ? Icons.sort_by_alpha
                        : Icons.history,
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
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book,
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
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localization.addWordsByPressingButton,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                    : WordsList(
                      currentDict: currentDict,
                      words: sortedWords,
                      onEditWord: (context, dictionary, word) {
                        _showEditWordDialog(
                          context,
                          dictionary,
                          word,
                          provider,
                        );
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
                            final dictProvider =
                                Provider.of<DictionaryProvider>(
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
      ),
    );
  }

  void _showEditWordDialog(
    BuildContext context,
    Dictionary currentDictionary,
    Word word,
    DictionaryProvider provider,
  ) {
    final localization = AppLocalizations.of(context)!;

    final actualIndex = currentDictionary.words.indexWhere(
      (w) => w.term == word.term && w.translation == word.translation,
    );

    if (actualIndex == -1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.failedToFindWordForEdit),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
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
      if (!mounted || result == null) {
        return;
      }

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localization.errorOccurred),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
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
    final localization = AppLocalizations.of(context)!;

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
            word.description != null && word.description!.trim().isNotEmpty;
        break;
      case DictionaryType.phrase:
      case DictionaryType.sentence:
        alignment = TextAlign.start;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.start;
        rowChildAlignment = Alignment.topLeft;
        descriptionVisible = false;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: onEdit,
        child: Tooltip(
          message: localization.holdToEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: crossAxisAlignmentItemAlignment,
              children: [
                IntrinsicHeight(
                  child: Row(
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
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
