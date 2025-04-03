import 'package:flutter/material.dart';
import '../data/dictionary.dart';

class AddWordScreen extends StatefulWidget {
  final Function(Word) onWordAdded;

  const AddWordScreen({
    required this.onWordAdded,
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

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newWord = Word(
        term: _termController.text.trim(),
        translation: _translationController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      widget.onWordAdded(newWord);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Додати нове слово'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _termController,
              decoration: const InputDecoration(
                labelText: 'Слово',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Будь ласка, введіть слово';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Переклад',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Будь ласка, введіть переклад';
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
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}