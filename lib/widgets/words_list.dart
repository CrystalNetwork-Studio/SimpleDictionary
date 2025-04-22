import 'package:flutter/material.dart';

import '../data/dictionary.dart';
import 'word_card.dart';

/// A list widget that displays a list of words.
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