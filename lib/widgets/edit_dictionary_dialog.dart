import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dictionary.dart';
import '../l10n/app_localizations.dart';
import '../providers/dictionary_provider.dart';

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

class EditDictionaryDialogResult {
  final EditDictionaryDialogStatus status;
  EditDictionaryDialogResult(this.status);
}

enum EditDictionaryDialogStatus { saved, cancelled, error }

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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localization.editDictionary),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localization.dictionaryNameLabel}:',
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: localization.dictionaryNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localization.dictionaryNameNotEmpty;
                  }
                  return null;
                },
                enabled: !_isSaving,
                onFieldSubmitted: (_) => _submitForm(),
              ),
              const SizedBox(height: 20),
              Text('${localization.folderColor}:', style: textTheme.titleSmall),
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
          child: Text(localization.cancel),
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
                  : Text(localization.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
            AppLocalizations.of(context)!.failedToUpdateDictionary;
        setState(() {
          _localError = error;
          _isSaving = false;
        });
        Provider.of<DictionaryProvider>(context, listen: false).clearError();
      }
    }
  }
}
