import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

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

enum SortOrder { alphabetical, lastAdded }

class WordCard extends StatefulWidget {
  final Word word;
  final int index;
  final String dictionaryName;
  final DictionaryProvider provider;
  final DictionaryType dictionaryType;
  final Function() onEdit;

  const WordCard({
    required this.word,
    required this.index,
    required this.dictionaryName,
    required this.provider,
    required this.dictionaryType,
    required this.onEdit,
    super.key,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class WordsList extends StatelessWidget {
  final Dictionary currentDict;
  final DictionaryProvider provider;
  final List<Word> words;
  final void Function(
    BuildContext context,
    Dictionary dictionary,
    int index,
    Word word,
  )
  onEditWord;

  const WordsList({
    required this.currentDict,
    required this.provider,
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
          index: index,
          dictionaryName: currentDict.name,
          provider: provider,
          dictionaryType: currentDict.type,
          onEdit: () => onEditWord(context, currentDict, index, word),
        );
      },
    );
  }
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  SortOrder _sortOrder = SortOrder.alphabetical;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionary.name),
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
            // Dictionary not found, show error message
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
                ],
              ),
            );
          }

          final currentDict = currentDictFromProvider;
          List<Word> words = List.from(currentDict.words);

          if (_sortOrder == SortOrder.alphabetical) {
            words.sort(
              (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
            );
          } else {
            // For 'lastAdded', we use the original order from the provider,
            // which is implicitly newest first if words are always added at the end.
            // No explicit sort needed, List.from() already created the copy.
          }

          if (words.isEmpty) {
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
                    localization.dictionaryEmpty,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            );
          }

          return WordsList(
            currentDict: currentDict,
            provider: provider,
            words: words,
            onEditWord: (
              BuildContext context,
              Dictionary dictionary,
              int index, // This index is based on the *sorted* list
              Word word,
            ) {
              _showEditWordDialog(context, dictionary, index, word);
            },
          );
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
                      // Use context safely before async gap
                      final dictProvider = Provider.of<DictionaryProvider>(
                        context,
                        listen: false,
                      );
                      dictProvider.clearError();
                      return await dictProvider.addWordToDictionary(
                        targetDictionaryName,
                        word,
                      );
                    },
                    dictionaryType: widget.dictionary.type,
                  ),
            ),
          );
        },
        tooltip: localization.addNewWord,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditWordDialog(
    BuildContext context,
    Dictionary currentDictionary,
    int originalIndexInSortedList,
    Word word,
  ) {
    final localization = AppLocalizations.of(context)!;
    // Access provider before the dialog is shown (before potential async gap)
    final provider = Provider.of<DictionaryProvider>(context, listen: false);

    // Find the *actual* index in the unsorted provider list
    // This is crucial because the list displayed might be sorted differently.
    final actualIndex = currentDictionary.words.indexWhere(
      (w) =>
          w ==
          word, // Assumes Word class has proper equality check or uses reference equality.
    );

    if (actualIndex == -1) {
      // Word might have been deleted concurrently.
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
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (dialogContext) {
        // We already have the provider from the outer scope, safe to use here.
        return EditWordDialog(
          initialWord: word, // Pass the specific word object
          dictionaryName: currentDictionary.name,
          wordIndex: actualIndex, // Use the index from the original list
          onWordUpdated: (indexFromDialog, updatedWord) async {
            provider.clearError();
            bool success = await provider.updateWordInDictionary(
              currentDictionary.name,
              indexFromDialog, // Should match actualIndex
              updatedWord,
            );
            return success;
          },
          onWordDeleted: (indexFromDialog) async {
            provider.clearError();
            final wordTermToDelete = word.term; // Capture term before deletion
            bool success = await provider.removeWordFromDictionary(
              currentDictionary.name,
              indexFromDialog, // Should match actualIndex
            );
            return success ? wordTermToDelete : null;
          },
          dictionaryType: currentDictionary.type,
        );
      },
    ).then((result) {
      // Check if the widget is still in the tree after the dialog closes.
      if (!mounted || result == null) return;

      // Use the localization obtained safely before the async gap.
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
                  localization.wordDeletedWithName(result.deletedWordTerm!),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Fallback message if term wasn't returned for some reason
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
          // No user feedback needed on cancellation.
          break;
        case EditWordDialogStatus.error:
          // Errors should ideally be handled within the provider/dialog
          // or shown via the provider's error state, but a generic
          // message here could be a fallback.
          // Example:
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(localization.operationFailed),
          //   backgroundColor: Theme.of(context).colorScheme.error,
          // ));
          break;
      }
    });
  }
}

class _WordCardState extends State<WordCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Default alignment for word/translation pairs
    TextAlign alignment = TextAlign.center;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;

    // Adjust alignment for longer text typical in sentence dictionaries
    if (widget.dictionaryType == DictionaryType.sentences) {
      alignment = TextAlign.start;
      crossAxisAlignment = CrossAxisAlignment.start;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onEdit, // Trigger the edit dialog
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: crossAxisAlignment, // Use determined alignment
            children: [
              IntrinsicHeight(
                // Ensures the Row children stretch to the same height
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment:
                            alignment == TextAlign.center
                                ? Alignment
                                    .center // Center short terms
                                : Alignment
                                    .centerLeft, // Left-align longer text
                        child: Text(
                          widget.word.term,
                          textAlign: alignment,
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          // Allow text to wrap if needed
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
                        alignment:
                            alignment == TextAlign.center
                                ? Alignment.center
                                : Alignment.centerLeft,
                        child: Text(
                          widget.word.translation,
                          textAlign: alignment,
                          style: textTheme.titleMedium,
                          maxLines: // Allow multiple lines for sentence translations
                              widget.dictionaryType == DictionaryType.sentences
                                  ? null
                                  : 1, // Limit regular translations visually
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conditionally display the description if it exists
              if (widget.word.description.isNotEmpty) ...[
                const Divider(height: 20, thickness: 0.5),
                Text(
                  widget.word.description,
                  style: textTheme.bodyMedium?.copyWith(
                    // Slightly faded color for description
                    color: textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                  textAlign:
                      TextAlign
                          .start, // Descriptions usually look better left-aligned
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
