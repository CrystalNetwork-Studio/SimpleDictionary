import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';

class AddWordScreen extends StatefulWidget {
  final Future<bool> Function(Word) onWordAdded;

  const AddWordScreen({required this.onWordAdded, super.key});

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

      // The length check is now primarily handled in the provider before saving
      final bool addedSuccessfully = await widget.onWordAdded(newWord);

      if (!mounted) return;

      if (addedSuccessfully) {
        Navigator.of(context).pop();
      } else {
        // Error message is now set in the provider.
        final error =
            Provider.of<DictionaryProvider>(context, listen: false).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Не вдалося додати слово.'),
            backgroundColor: Colors.orange,
          ),
        );
        // Clear provider error after showing it
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed limitChars as it's always true (words dictionary)
    return Scaffold(
      appBar: AppBar(title: const Text('Додати нове слово')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _termController,
              maxLength: 20,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              decoration: InputDecoration(
                labelText: 'Слово',
                counterText: "",
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Будь ласка, введіть слово';
                }
                if (value.length > 20) {
                  // This validator might not be strictly needed if maxLength is enforced
                  return 'Максимум 20 символів';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _translationController,
              maxLength: 20,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              decoration: InputDecoration(
                labelText: 'Переклад',
                counterText: "", // Hide the default counter
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Будь ласка, введіть переклад';
                }
                if (value.length > 20) {
                  // This validator might not be strictly needed if maxLength is enforced
                  return 'Максимум 20 символів';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Опис',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // Keep multiline for description
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
                          // Use theme color for indicator
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                      : const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}
