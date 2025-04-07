import 'package:flutter/material.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../data/dictionary.dart';

class CreateDictionaryDialog extends StatefulWidget {
  final Function(String, Color, DictionaryType) onCreate;
  final Future<bool> Function(String) dictionaryExists;

  const CreateDictionaryDialog({
    required this.onCreate,
    required this.dictionaryExists,
    super.key,
  });

  @override
  State<CreateDictionaryDialog> createState() => _CreateDictionaryDialogState();
}

class _CreateDictionaryDialogState extends State<CreateDictionaryDialog> {
  final _textController = TextEditingController();
  bool _canCreate = false;
  String? _errorMessage;
  Color _selectedColor = Colors.blue;
  DictionaryType _selectedType = DictionaryType.word;
  bool _isLoading = false;

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

  String _getDictionaryTypeText(
    DictionaryType type,
    AppLocalizations localization,
  ) {
    switch (type) {
      case DictionaryType.word:
        return localization.words;
      case DictionaryType.phrase:
        return localization.sentences;
      case DictionaryType.sentence:
        return localization.sentence;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localization.createDictionary),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localization.dictionaryNameLabel, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: localization.dictionaryNameHint,
                errorText: _errorMessage,
                suffixIcon:
                    _isLoading
                        ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : null,
              ),
              enabled: !_isLoading,
              onChanged: (_) => _validateName(),
              onSubmitted:
                  (_canCreate && !_isLoading) ? (_) => _submit() : null,
            ),
            const SizedBox(height: 16),
            // Dictionary Type Selection
            Text(localization.dictionaryType, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<DictionaryType>(
              value: _selectedType,
              items:
                  DictionaryType.values
                      .map(
                        (DictionaryType type) =>
                            DropdownMenuItem<DictionaryType>(
                              value: type,
                              child: Text(
                                _getDictionaryTypeText(type, localization),
                              ),
                            ),
                      )
                      .toList(),
              onChanged:
                  _isLoading
                      ? null
                      : (DictionaryType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        }
                      },
              decoration: InputDecoration(
                // Optional: Add border or customize decoration
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
              disabledHint: Text(
                _getDictionaryTypeText(_selectedType, localization),
              ), // Show current value when disabled
            ),
            const SizedBox(height: 20),
            Text(localization.folderColor, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _colorOptions.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () {
                                    setState(() => _selectedColor = color);
                                  },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
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
                                                        color,
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
            if (_isLoading) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  localization.checkingAvailability,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            if (_errorMessage != null && !_isLoading) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(localization.cancel),
        ),
        TextButton(
          onPressed: (_canCreate && !_isLoading) ? _submit : null,
          child: Text(localization.create),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_validateName);
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_validateName);
  }

  Future<void> _submit() async {
    final dictionaryName = _textController.text.trim();
    if (dictionaryName.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _canCreate = false;
    });

    bool exists = false;
    String? checkErrorMsg;
    try {
      exists = await widget.dictionaryExists(dictionaryName);
    } catch (e) {
      debugPrint('Error checking dictionary existence: $e');
      if (mounted) {
        checkErrorMsg = AppLocalizations.of(context)!.errorValidatingNameDialog;
      } else {
        checkErrorMsg = 'Error validating name.';
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (checkErrorMsg != null) {
        _errorMessage = checkErrorMsg;
        _canCreate = false;
      } else if (exists) {
        _errorMessage = AppLocalizations.of(context)!.dictionaryAlreadyExists;
        _canCreate = false;
      } else {
        _errorMessage = null;
        _canCreate = true;
        widget.onCreate(dictionaryName, _selectedColor, _selectedType);
        Navigator.of(context).pop();
      }
    });
  }

  void _validateName() {
    if (_isLoading) return;

    final text = _textController.text.trim();
    final isNotEmpty = text.isNotEmpty;
    final bool needsStateUpdate =
        (isNotEmpty != _canCreate) || (_errorMessage != null && isNotEmpty);

    if (needsStateUpdate) {
      setState(() {
        _canCreate = isNotEmpty;
        if (isNotEmpty) {
          _errorMessage = null;
        }
      });
    } else if (!isNotEmpty && _canCreate) {
      setState(() {
        _canCreate = false;
      });
    }
  }
}
