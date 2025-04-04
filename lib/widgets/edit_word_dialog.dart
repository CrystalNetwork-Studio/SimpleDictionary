import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';

// Define result types
enum EditWordDialogStatus { saved, deleted, cancelled, error }

class EditWordDialogResult {
  final EditWordDialogStatus status;
  final String? deletedWordTerm;

  EditWordDialogResult(this.status, {this.deletedWordTerm});
}

class EditWordDialog extends StatefulWidget {
  final String dictionaryName;
  final int wordIndex;
  final Word initialWord;
  final Future<bool> Function(int, Word) onWordUpdated;
  final Future<String?> Function(int) onWordDeleted;

  const EditWordDialog({
    required this.dictionaryName,
    required this.wordIndex,
    required this.initialWord,
    required this.onWordUpdated,
    required this.onWordDeleted,
    super.key,
  });

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _termController;
  late TextEditingController _translationController;
  late TextEditingController _descriptionController;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _localError; // For displaying errors

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

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          _localError = error ?? 'Не вдалося оновити слово.';
          _isSaving = false;
        });
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }
    }
  }

  Future<void> _handleDelete() async {
    if (_isSaving || _isDeleting) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Підтвердити видалення'),
            content: Text('Видалити слово "${widget.initialWord.term}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Видалити'),
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
        _localError = error ?? 'Не вдалося видалити слово.';
        _isDeleting = false;
      });
      Provider.of<DictionaryProvider>(context, listen: false).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !_isSaving && !_isDeleting;

    return AlertDialog(
      title: const Text('Редагувати слово'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    return 'Максимум 20 символів';
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _translationController,
                maxLength: 20,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                  labelText: 'Переклад',
                  counterText: "",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Будь ласка, введіть переклад';
                  }
                  if (value.length > 20) {
                    return 'Максимум 20 символів';
                  }
                  return null;
                },
                enabled: canInteract,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Опис (необов\'язково)',
                  border: OutlineInputBorder(),
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
            'Видалити',
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
                        EditWordDialogResult(EditWordDialogStatus.cancelled),
                      )
                      : null,
              child: const Text('Скасувати'),
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
                      : const Text('Зберегти'),
            ),
          ],
        ),
      ],
    );
  }
}
