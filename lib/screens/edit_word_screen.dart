import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../providers/dictionary_provider.dart';

class EditWordDialog extends StatefulWidget {
  final String dictionaryName;
  final int wordIndex;
  final Word initialWord;

  /// Async function to update the word. Returns true on success.
  final Future<bool> Function(int, Word) onWordUpdated;

  /// Async function to delete the word. Returns the term of the deleted word on success, null on failure.
  final Future<String?> Function(int) onWordDeleted;
  final DictionaryType dictionaryType; // Affects fields and validation
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
  State<EditWordDialog> createState() => _EditWordDialogState();
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

class _EditWordDialogState extends State<EditWordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _termController;
  late TextEditingController _translationController;
  late TextEditingController _descriptionController;
  // State flags to manage the UI (disable buttons, show indicators).
  bool _isSaving = false;
  bool _isDeleting = false;
  // String to display local errors within the dialog.
  String? _localError;

  @override
  Widget build(BuildContext context) {
    final dictionaryProvider = Provider.of<DictionaryProvider>(
      context,
      listen: false,
    );
    final localization = AppLocalizations.of(context)!;

    /// Whether fields/buttons can be interacted with.
    final bool canInteract = !_isSaving && !_isDeleting;
    final bool isSentence = widget.dictionaryType == DictionaryType.sentence;
    final bool isWord = widget.dictionaryType == DictionaryType.word;
    final Color errorColor = Theme.of(context).colorScheme.error;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localization.editWord),
          IconButton(
            // Show indicator or icon based on _isDeleting state
            icon: _isDeleting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: errorColor,
                    ),
                  )
                : Icon(Icons.delete_outline, color: errorColor),
            tooltip: localization.delete,
            onPressed:
                canInteract ? () => _handleDelete(dictionaryProvider) : null,
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _termController,
                maxLength: isWord ? 13 : null,
                inputFormatters:
                    isWord ? [LengthLimitingTextInputFormatter(23)] : null,
                decoration: InputDecoration(
                  labelText: localization.word,
                  counterText: "", // Hide default counter
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.pleaseEnterWord;
                  }
                  if (isWord && value.length > 13) {
                    return localization.maxLength23;
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _translationController,
                maxLength: isWord ? 13 : null,
                inputFormatters:
                    isWord ? [LengthLimitingTextInputFormatter(23)] : null,
                decoration: InputDecoration(
                  labelText: localization.translation,
                  counterText: "",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.pleaseEnterTranslation;
                  }
                  if (isWord && value.length > 13) {
                    return localization.maxLength23;
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),

              // Description field only for 'word' type dictionaries
              if (!isSentence)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: localization.descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: canInteract,
                  // No validator, field is optional
                ),

              // Display local errors (save/delete failures)
              if (_localError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _localError!,
                  style: TextStyle(color: errorColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: canInteract ? () => _submitForm(dictionaryProvider) : null,
          // Show indicator or text based on _isSaving state
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onPrimaryColor,
                  ),
                )
              : Text(localization.save),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _termController = TextEditingController(text: widget.initialWord.term);
    _translationController = TextEditingController(
      text: widget.initialWord.translation,
    );
    _descriptionController = TextEditingController(
      text: widget.initialWord.description ?? '',
    );
  }

  /// Handles the word deletion process including confirmation.
  Future<void> _handleDelete(DictionaryProvider provider) async {
    final localization = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localization.confirmDeletion),
        content: Text(
          localization.confirmDeleteWord(widget.initialWord.term),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // Cancel
            child: Text(localization.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true), // Confirm
            child: Text(localization.delete),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return; // User cancelled
    }

    setState(() {
      _isDeleting = true;
      _localError = null;
    });

    // Call the callback provided by the parent widget
    final String? deletedTerm = await widget.onWordDeleted(widget.wordIndex);

    if (!mounted) return; // Check if widget is still in the tree

    if (deletedTerm != null) {
      // Success
      Navigator.of(context).pop(
        EditWordDialogResult(
          EditWordDialogStatus.deleted,
          deletedWordTerm: deletedTerm,
        ),
      );
    } else {
      // Failure
      final errorMsg = provider.error ?? localization.failedToDeleteWord;
      setState(() {
        _localError = errorMsg;
        _isDeleting = false;
      });
      provider.clearError();
    }
  }

  /// Handles the word saving (update) process after form validation.
  Future<void> _submitForm(DictionaryProvider provider) async {
    final localization = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate() && !_isSaving && !_isDeleting) {
      setState(() {
        _isSaving = true;
        _localError = null;
      });

      // Create updated word object from controllers
      final updatedWord = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        // Handle optional description, ensuring null for sentences
        description: widget.dictionaryType != DictionaryType.sentence
            ? (_descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim())
            : null,
      );

      // Call the callback provided by the parent widget
      final bool updatedSuccessfully = await widget.onWordUpdated(
        widget.wordIndex,
        updatedWord,
      );

      if (!mounted) return; // Check if widget is still in the tree

      if (updatedSuccessfully) {
        // Success
        Navigator.of(context).pop(
          EditWordDialogResult(EditWordDialogStatus.saved),
        );
      } else {
        // Failure
        final errorMsg = provider.error ?? localization.failedToUpdateWord;
        setState(() {
          _localError = errorMsg;
          _isSaving = false;
        });
        provider.clearError();
      }
    }
  }
}
