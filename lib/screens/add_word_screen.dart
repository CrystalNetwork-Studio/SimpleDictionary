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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNewWord)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _termController,
              maxLength:
                  widget.dictionaryType == DictionaryType.words ? 20 : null,
              inputFormatters:
                  widget.dictionaryType == DictionaryType.words
                      ? [LengthLimitingTextInputFormatter(20)]
                      : null,
              decoration: InputDecoration(
                labelText: l10n.word,
                counterText:
                    widget.dictionaryType == DictionaryType.words ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterWord;
                }
                if (widget.dictionaryType == DictionaryType.words &&
                    value.length > 20) {
                  return l10n.maxLength20;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _translationController,
              maxLength:
                  widget.dictionaryType == DictionaryType.words ? 20 : null,
              inputFormatters:
                  widget.dictionaryType == DictionaryType.words
                      ? [LengthLimitingTextInputFormatter(20)]
                      : null,
              decoration: InputDecoration(
                labelText: l10n.translation,
                counterText:
                    widget.dictionaryType == DictionaryType.words ? "" : null,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTranslation;
                }
                if (widget.dictionaryType == DictionaryType.words &&
                    value.length > 20) {
                  return l10n.maxLength20;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
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
        description: _descriptionController.text.trim(),
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
            backgroundColor: Colors.orange,
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
