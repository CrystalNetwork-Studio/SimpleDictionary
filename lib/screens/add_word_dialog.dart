import 'package:flutter/material.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../widgets/word_form_widget.dart';

class AddWordDialog extends StatelessWidget {
  final Future<bool> Function(Word) onWordAdded;
  final DictionaryType dictionaryType;
  final int? maxLength;

  const AddWordDialog({
    required this.onWordAdded,
    required this.dictionaryType,
    this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addNewWord),
      content: SingleChildScrollView(
        child: WordFormWidget(
          dictionaryType: dictionaryType,
          maxLength: maxLength,
          onSave: (word) async {
            final bool addedSuccessfully = await onWordAdded(word);

            if (addedSuccessfully && context.mounted) {
              Navigator.of(context).pop(true);
            }

            return addedSuccessfully;
          },
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: EdgeInsets.zero,
      // No actions needed as they're included in the WordFormWidget
    );
  }
}

class AddWordDialogResult {
  final bool success;

  AddWordDialogResult(this.success);
}
