import 'package:flutter/material.dart';
import '../data/dictionary.dart';
import 'dictionary_item.dart';

class DictionaryList extends StatelessWidget {
  final List<Dictionary> dictionaries;

  const DictionaryList({required this.dictionaries, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: dictionaries.length,
      itemBuilder: (context, index) {
        final dictionary = dictionaries[index];
        return DictionaryItem(
          key: ObjectKey(dictionary),
          dictionary: dictionary,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 4),
    );
  }
}
