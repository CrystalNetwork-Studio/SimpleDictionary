import 'package:flutter/material.dart';

import '../data/dictionary.dart';

/// A card widget that displays a word and its translation.
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
    Alignment rowChildAlignment = Alignment.topLeft;
    bool descriptionVisible = false;

    switch (dictionaryType) {
      case DictionaryType.word:
        alignment = TextAlign.center;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.center;
        rowChildAlignment = Alignment.topLeft;
        // descriptionVisible = dictionaryType != DictionaryType.sentence &&
        //     word.description != null &&
        //     word.description!.trim().isNotEmpty;
        descriptionVisible = false;
        break;
      case DictionaryType.phrase:
        alignment = TextAlign.start;
        crossAxisAlignmentItemAlignment = CrossAxisAlignment.start;
        // descriptionVisible = dictionaryType != DictionaryType.phrase &&
        //     word.description != null &&
        //     word.description!.trim().isNotEmpty;
        descriptionVisible = false;

        break;
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
        onTap: onEdit,
        onLongPress: onEdit,
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
    );
  }
}
