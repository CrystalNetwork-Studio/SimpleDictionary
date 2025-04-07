import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../providers/dictionary_provider.dart';

class AddWordScreen extends StatefulWidget {
  final Future<bool> Function(Word) onWordAdded;
  final DictionaryType dictionaryType;

  const AddWordScreen({
    required this.onWordAdded,
    required this.dictionaryType,
    super.key,
  });

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _translationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  int? _maxLength;
  bool _descriptionAllowed = true;

  @override
  void initState() {
    super.initState();
    switch (widget.dictionaryType) {
      case DictionaryType.word:
        _maxLength = 14;
        _descriptionAllowed = true;
        break;
      case DictionaryType.phrase:
        _maxLength = 23;
        _descriptionAllowed = false;
        break;
      case DictionaryType.sentence:
        _maxLength = null;
        _descriptionAllowed = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lengthFormatters =
        _maxLength != null
            ? [LengthLimitingTextInputFormatter(_maxLength)]
            : <TextInputFormatter>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNewWord)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _termController,
              maxLength: _maxLength,
              inputFormatters: lengthFormatters,
              decoration: InputDecoration(
                labelText: l10n.word,
                counterText: _maxLength != null ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterWord;
                }
                if (_maxLength != null && value.length > _maxLength!) {
                  return l10n.maxLengthValidation(_maxLength!);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _translationController,
              maxLength: _maxLength,
              inputFormatters: lengthFormatters,
              decoration: InputDecoration(
                labelText: l10n.translation,
                counterText: _maxLength != null ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTranslation;
                }
                if (_maxLength != null && value.length > _maxLength!) {
                  return l10n.maxLengthValidation(_maxLength!);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_descriptionAllowed)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            if (_descriptionAllowed) const SizedBox(height: 24),
            if (!_descriptionAllowed) const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isSaving ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
                      : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() {
        _isSaving = true;
      });

      final newWord = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        description:
            _descriptionAllowed && _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
      );

      final bool addedSuccessfully = await widget.onWordAdded(newWord);

      if (!mounted) return;

      if (addedSuccessfully) {
        Navigator.of(context).pop();
      } else {
        final error =
            Provider.of<DictionaryProvider>(context, listen: false).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? AppLocalizations.of(context)!.failedToAddWord,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }

      setState(() {
        _isSaving = false;
      });
    }
  }
}
