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
  final Future<bool> Function(int, Word) onWordUpdated;
  final Future<String?> Function(int) onWordDeleted;
  final DictionaryType dictionaryType;

  const EditWordDialog({
    required this.dictionaryName,
    required this.wordIndex,
    required this.initialWord,
    required this.onWordUpdated,
    required this.onWordDeleted,
    required this.dictionaryType,
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

enum EditWordDialogStatus { saved, deleted, cancelled, error }

class _EditWordDialogState extends State<EditWordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _termController;
  late TextEditingController _translationController;
  late TextEditingController _descriptionController;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _localError;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !_isSaving && !_isDeleting;
    final localization = AppLocalizations.of(context)!;
    final bool isSentence = widget.dictionaryType == DictionaryType.sentence;

    return AlertDialog(
      title: Text(localization.editWord),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _termController,
                maxLength:
                    widget.dictionaryType == DictionaryType.word ? 20 : null,
                inputFormatters:
                    widget.dictionaryType == DictionaryType.word
                        ? [LengthLimitingTextInputFormatter(20)]
                        : null,
                decoration: InputDecoration(
                  labelText: localization.word,
                  counterText: "",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.pleaseEnterWord;
                  }
                  if (widget.dictionaryType == DictionaryType.word &&
                      value.length > 20) {
                    return localization.maxLength20;
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _translationController,
                maxLength:
                    widget.dictionaryType == DictionaryType.word ? 20 : null,
                inputFormatters:
                    widget.dictionaryType == DictionaryType.word
                        ? [LengthLimitingTextInputFormatter(20)]
                        : null,
                decoration: InputDecoration(
                  labelText: localization.translation,
                  counterText: "",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.pleaseEnterTranslation;
                  }
                  if (widget.dictionaryType == DictionaryType.word &&
                      value.length > 20) {
                    return localization.maxLength20;
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),
              if (!isSentence)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: localization.descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: canInteract,
                ),
              if (_localError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _localError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon:
                  _isDeleting
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                      : Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
              label: Text(
                localization.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: canInteract ? _handleDelete : null,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed:
                      canInteract
                          ? () => Navigator.of(context).pop(
                            EditWordDialogResult(
                              EditWordDialogStatus.cancelled,
                            ),
                          )
                          : null,
                  child: Text(localization.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canInteract ? _submitForm : null,
                  child:
                      _isSaving
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                          : Text(localization.save),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
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
      text: widget.initialWord.description,
    );
  }

  Future<void> _handleDelete() async {
    if (_isSaving || _isDeleting) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeletion),
            content: Text(
              AppLocalizations.of(
                context,
              )!.confirmDeleteWord(widget.initialWord.term),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _localError = null;
    });

    final String? deletedTerm = await widget.onWordDeleted(widget.wordIndex);

    if (!mounted) return;

    if (deletedTerm != null) {
      Navigator.of(context).pop(
        EditWordDialogResult(
          EditWordDialogStatus.deleted,
          deletedWordTerm: deletedTerm,
        ),
      );
    } else {
      final error =
          Provider.of<DictionaryProvider>(context, listen: false).error;
      setState(() {
        _localError = error ?? AppLocalizations.of(context)!.failedToDeleteWord;
        _isDeleting = false;
      });
      Provider.of<DictionaryProvider>(context, listen: false).clearError();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSaving && !_isDeleting) {
      setState(() {
        _isSaving = true;
        _localError = null;
      });

      final updatedWord = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      final bool updatedSuccessfully = await widget.onWordUpdated(
        widget.wordIndex,
        updatedWord,
      );

      if (!mounted) return;

      if (updatedSuccessfully) {
        Navigator.of(
          context,
        ).pop(EditWordDialogResult(EditWordDialogStatus.saved));
      } else {
        final error =
            Provider.of<DictionaryProvider>(context, listen: false).error;
        setState(() {
          _localError =
              error ?? AppLocalizations.of(context)!.failedToUpdateWord;
          _isSaving = false;
        });
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }
    }
  }
}
