import 'package:flutter/material.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../widgets/word_form_widget.dart';

class EditWordDialog extends StatelessWidget {
  final String dictionaryName;
  final int wordIndex;
  final Word initialWord;

  /// Async function to update the word. Returns true on success.
  final Future<bool> Function(int, Word) onWordUpdated;

  /// Async function to delete the word. Returns the term of the deleted word on success, null on failure.
  final Future<String?> Function(int) onWordDeleted;
  final DictionaryType dictionaryType;
  final int? maxLength;

  const EditWordDialog({
    required this.dictionaryName,
    required this.wordIndex,
    required this.initialWord,
    required this.onWordUpdated,
    required this.onWordDeleted,
    required this.dictionaryType,
    this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editWord),
      content: SingleChildScrollView(
        child: WordFormWidget(
          initialWord: initialWord,
          dictionaryType: dictionaryType,
          isEditMode: true,
          maxLength: maxLength,
          onSave: (word) async {
            final success = await onWordUpdated(wordIndex, word);
            if (success && context.mounted) {
              Navigator.of(context).pop(
                EditWordDialogResult(
                  EditWordDialogStatus.saved,
                ),
              );
            }
            return success;
          },
          onDelete: () async {
            final deletedTerm = await onWordDeleted(wordIndex);
            if (deletedTerm != null && context.mounted) {
              Navigator.of(context).pop(
                EditWordDialogResult(
                  EditWordDialogStatus.deleted,
                  deletedWordTerm: deletedTerm,
                ),
              );
            }
            return deletedTerm;
          },
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: EdgeInsets.zero,
      // No actions needed as they're included in the WordFormWidget
    );
  }
}

class EditWordDialogResult {
  final EditWordDialogStatus status;
  final String? deletedWordTerm;

  EditWordDialogResult(this.status, {this.deletedWordTerm});
}

// Defines the outcome of the operation within the dialog.
enum EditWordDialogStatus {
  saved,
  deleted,
  error,
  // 'cancelled' is handled by showDialog returning null
}
