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
          // Return UI indicating dictionary not found
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
                    // UI for empty dictionary
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
                    // List of words
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

    // Find the actual index in the potentially unsorted list from the provider
    final actualIndex = currentDictionary.words.indexWhere(
      (w) => w.term == word.term && w.translation == word.translation,
    );

    if (actualIndex == -1) {
      // Handle case where word is not found (should ideally not happen if UI is in sync)
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
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (dialogContext) {
        return EditWordDialog(
          initialWord: word,
          dictionaryName: currentDictionary.name,
          wordIndex: actualIndex, // Use the found index
          dictionaryType: currentDictionary.type,
          onWordUpdated: (indexFromDialog, updatedWord) async {
            provider.clearError();
            // Use indexFromDialog which corresponds to the actualIndex passed initially
            bool success = await provider.updateWordInDictionary(
              currentDictionary.name,
              indexFromDialog,
              updatedWord,
              context:
                  dialogContext, // Use dialog context for provider operations
            );
            return success;
          },
          onWordDeleted: (indexFromDialog) async {
            provider.clearError();
            // Use indexFromDialog which corresponds to the actualIndex passed initially
            final wordTermToDelete =
                currentDictionary.words[indexFromDialog].term;
            bool success = await provider.removeWordFromDictionary(
              currentDictionary.name,
              indexFromDialog,
              context:
                  dialogContext, // Use dialog context for provider operations
            );
            return success ? wordTermToDelete : null;
          },
        );
      },
    ).then((result) {
      if (!mounted || result == null) {
        return; // Check if widget is still mounted
      }

      // Handle the result from the dialog (show snackbars)
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
                  localization.wordDeletedWithName(
                    result.deletedWordTerm!,
                    '',
                  ), // Ensure localization handles potential null
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localization.wordDeleted,
                ), // Generic deletion message
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          break;
        case EditWordDialogStatus.cancelled:
          // No action needed for cancellation
          break;
        case EditWordDialogStatus.error:
          // Error handling might already be done by the provider,
          // but you could show a generic error snackbar here if needed.
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
      // Add padding around the list
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        // Use a unique key for each word card for better performance and state management
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

    // Determine layout based on dictionary type
    switch (dictionaryType) {
      case DictionaryType.word:
        alignment = TextAlign.center; // Center text within Text widget
        crossAxisAlignmentItemAlignment =
            CrossAxisAlignment.center; // Center items vertically in Column
        rowChildAlignment =
            Alignment.center; // Center Text widget within Expanded cell
        descriptionVisible =
            word.description != null && word.description!.isNotEmpty;
        break;
      case DictionaryType.phrase:
      case DictionaryType.sentence:
        alignment =
            TextAlign
                .start; // Align text to the start (left) within Text widget
        crossAxisAlignmentItemAlignment =
            CrossAxisAlignment.start; // Align items to the top in Column
        rowChildAlignment =
            Alignment
                .topLeft; // Align Text widget to top-left within Expanded cell
        descriptionVisible =
            false; // Description not shown for phrases/sentences
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Spacing between cards
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Use GestureDetector for long press detection
      child: GestureDetector(
        onLongPressStart: (_) {
          // Optionally show a hint that long press is available
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(l10n.holdToEdit),
          //     duration: const Duration(milliseconds: 1500),
          //     behavior: SnackBarBehavior.floating,
          //   ),
          // );
        },
        onLongPress: onEdit, // Trigger edit on long press
        child: Container(
          // Ensure padding and decoration are applied to the container
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment:
                crossAxisAlignmentItemAlignment, // Apply vertical alignment for Column children
            children: [
              IntrinsicHeight(
                // Ensures Row children have the same height
                child: Row(
                  // Default crossAxisAlignment is center, which works well here
                  children: [
                    Expanded(
                      child: Align(
                        alignment:
                            rowChildAlignment, // Align Text within Expanded
                        child: Text(
                          word.term,
                          textAlign: alignment, // Align text lines within Text
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: null, // Allow multiple lines
                          softWrap: true,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ), // Separator
                    ),
                    Expanded(
                      child: Align(
                        alignment:
                            rowChildAlignment, // Align Text within Expanded
                        child: Text(
                          word.translation,
                          textAlign: alignment, // Align text lines within Text
                          style: textTheme.titleMedium,
                          maxLines: null, // Allow multiple lines
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conditionally display description for word types
              if (descriptionVisible) ...[
                const Divider(
                  height: 20,
                  thickness: 0.5,
                ), // Separator for description
                Align(
                  alignment:
                      Alignment.centerLeft, // Always align description left
                  child: Text(
                    word.description!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: textTheme.bodySmall?.color?.withOpacity(
                        0.8,
                      ), // Slightly faded color
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
