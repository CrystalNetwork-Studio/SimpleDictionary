import 'package:flutter/material.dart';
import '../data/dictionary.dart';
import 'dictionary_item.dart';

class DictionaryList extends StatelessWidget {
  final List<Dictionary> dictionaries;

  const DictionaryList({required this.dictionaries, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dictionaries.length,
      itemBuilder: (context, index) {
        final dictionary = dictionaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DictionaryItem(
            key: ValueKey(dictionary.name),
            dictionary: dictionary,
          ),
        );
      },
    );
  }
}
