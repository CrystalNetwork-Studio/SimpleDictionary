import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dictionary.dart';
import '../providers/dictionary_provider.dart';

enum EditDictionaryDialogStatus { saved, cancelled, error }

class EditDictionaryDialogResult {
  final EditDictionaryDialogStatus status;
  EditDictionaryDialogResult(this.status);
}

class EditDictionaryDialog extends StatefulWidget {
  final Dictionary initialDictionary;
  final Future<bool> Function(String oldName, String newName, Color newColor)
  onDictionaryUpdated;
  final Future<bool> Function(String name) dictionaryExists;

  const EditDictionaryDialog({
    required this.initialDictionary,
    required this.onDictionaryUpdated,
    required this.dictionaryExists,
    super.key,
  });

  @override
  State<EditDictionaryDialog> createState() => _EditDictionaryDialogState();
}

class _EditDictionaryDialogState extends State<EditDictionaryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;
  bool _isSaving = false;
  String? _localError;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDictionary.name,
    );
    _selectedColor = widget.initialDictionary.color;
    _nameController.addListener(() {
      if (_localError != null) {
        setState(() => _localError = null);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      final String oldName = widget.initialDictionary.name;
      final String newName = _nameController.text.trim();
      final Color newColor = _selectedColor;

      if (newName == oldName &&
          newColor.value == widget.initialDictionary.color.value) {
        Navigator.of(
          context,
        ).pop(EditDictionaryDialogResult(EditDictionaryDialogStatus.cancelled));
        return;
      }

      setState(() {
        _isSaving = true;
        _localError = null;
      });

      bool nameConflict = false;
      if (newName != oldName) {
        try {
          nameConflict = await widget.dictionaryExists(newName);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _localError = 'Помилка перевірки імені: $e';
            _isSaving = false;
          });
          return;
        }
      }

      if (nameConflict) {
        if (!mounted) return;
        setState(() {
          _localError = 'Словник з назвою "$newName" вже існує.';
          _isSaving = false;
        });
        return;
      }

      final bool updatedSuccessfully = await widget.onDictionaryUpdated(
        oldName,
        newName,
        newColor,
      );

      if (!mounted) return;

      if (updatedSuccessfully) {
        Navigator.of(
          context,
        ).pop(EditDictionaryDialogResult(EditDictionaryDialogStatus.saved));
      } else {
        final error =
            Provider.of<DictionaryProvider>(context, listen: false).error ??
            'Не вдалося оновити словник.';
        setState(() {
          _localError = error;
          _isSaving = false;
        });
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Редагувати Словник'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Назва:', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Назва словнику'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Назва не може бути порожньою';
                  }
                  return null;
                },
                enabled: !_isSaving,
                onFieldSubmitted: (_) => _submitForm(),
              ),
              const SizedBox(height: 20),

              Text('Колір папки:', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _colorOptions.map((colorOption) {
                          final bool isSelected =
                              _selectedColor.value == colorOption.value;
                          return GestureDetector(
                            onTap:
                                _isSaving
                                    ? null
                                    : () {
                                      setState(
                                        () => _selectedColor = colorOption,
                                      );
                                    },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorOption,
                                  shape: BoxShape.circle,
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.9),
                                            width: 3.0,
                                          )
                                          : Border.all(
                                            color: colorScheme.outlineVariant,
                                            width: 1,
                                          ),
                                ),
                                child: Center(
                                  child:
                                      isSelected
                                          ? Icon(
                                            Icons.check,
                                            color:
                                                ThemeData.estimateBrightnessForColor(
                                                          colorOption,
                                                        ) ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            size: 22,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
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
      actions: <Widget>[
        TextButton(
          onPressed:
              _isSaving
                  ? null
                  : () => Navigator.of(context).pop(
                    EditDictionaryDialogResult(
                      EditDictionaryDialogStatus.cancelled,
                    ),
                  ),
          child: const Text('Відмінити'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submitForm,
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
    );
  }
}
