import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for AnnotatedRegion
import 'package:provider/provider.dart';
import 'package:simpledictionary/data/dictionary.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:simpledictionary/providers/dictionary_provider.dart';
import 'package:simpledictionary/widgets/words_list.dart';

import '../../main.dart';

import '../widgets/add_word_dialog.dart';
import '../widgets/edit_word_dialog.dart';

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
    // Get SystemUiOverlayStyle from MyApp
    final systemUiOverlayStyle = MyApp.getAppSystemUIOverlayStyle(context);

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
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemUiOverlayStyle, // Apply here too
            child: _buildDictionaryNotFoundScreen(localization),
          );
        }

        final List<Word> sortedWords = _getSortedWords(
          currentDict,
          _sortOrder,
        );
        final DictionaryType dictionaryType = currentDict.type;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlayStyle, // Apply here
          child: Scaffold(
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
                      _sortOrder = _sortOrder == SortOrder.alphabetical
                          ? SortOrder.lastAdded
                          : SortOrder.alphabetical;
                    });
                  },
                  tooltip: _sortOrder == SortOrder.alphabetical
                      ? localization.sortByLastAdded
                      : localization.sortByAlphabetical,
                ),
              ],
            ),
            body: sortedWords.isEmpty
                ? _buildEmptyDictionaryView(localization)
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
              onPressed: () =>
                  _navigateToAddWord(context, currentDict!, dictionaryType),
              tooltip: dictionaryType == DictionaryType.word
                  ? localization.addNewWord
                  : dictionaryType == DictionaryType.phrase
                      ? localization.addNewPhrase
                      : localization.addNewSentence,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDictionaryNotFoundScreen(AppLocalizations localization) {
    // This Scaffold will be wrapped in AnnotatedRegion by the calling code.
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildEmptyDictionaryView(AppLocalizations localization) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withAlpha((0.6 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              localization.dictionaryEmpty,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }

  void _navigateToAddWord(BuildContext context, Dictionary currentDict,
      DictionaryType dictionaryType) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AddWordDialog(
          dictionaryType: dictionaryType,
          onWordAdded: (newWord) async {
            final dictProvider = Provider.of<DictionaryProvider>(
              context,
              listen: false,
            );
            dictProvider.clearError();
            return await dictProvider.addWordToDictionary(
              currentDict.name,
              newWord,
              context: dialogContext,
            );
          },
        );
      },
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
      barrierDismissible: true,
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.wordUpdatedSuccessfully),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
        case EditWordDialogStatus.deleted:
          if (result.deletedWordTerm != null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localization
                      .wordDeletedWithName(result.deletedWordTerm!)),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localization.wordDeleted),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
          break;
        case EditWordDialogStatus.error:
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.errorOccurred),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
      }
    });
  }
}
