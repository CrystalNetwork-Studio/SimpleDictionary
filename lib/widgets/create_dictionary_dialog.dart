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
  DictionaryType _selectedType = DictionaryType.words;
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localization = AppLocalizations.of(context)!;

    // Temporary hardcoded strings - replace with localization keys once added
    const String dictionaryTypeLabel = "Dictionary Type";
    const String wordsLabel = "Words";
    const String sentencesLabel = "Sentences";

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
            // Dictionary Type Selection Row
            Row(
              children: [
                Text(
                  '$dictionaryTypeLabel: ', // Use hardcoded label
                  style: textTheme.titleSmall,
                ),
                InkWell(
                  onTap:
                      _isLoading
                          ? null
                          : () {
                            setState(() {
                              _selectedType =
                                  _selectedType == DictionaryType.words
                                      ? DictionaryType.sentences
                                      : DictionaryType.words;
                            });
                          },
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Add splash effect area
                  child: Padding(
                    // Add padding for easier tapping
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedType == DictionaryType.words
                              ? wordsLabel // Use hardcoded label
                              : sentencesLabel, // Use hardcoded label
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ],
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
            if (_errorMessage != null) ...[
              // Display error message if present
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

    // Clear previous error message before attempting to submit
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool exists = false;
    String? checkErrorMsg;
    try {
      exists = await widget.dictionaryExists(dictionaryName);
    } catch (e) {
      // Consider using a logging framework here instead of print
      print('Error checking dictionary existence: $e');
      checkErrorMsg = AppLocalizations.of(context)!.errorValidatingNameDialog;
    }

    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = false; // Stop loading indicator regardless of outcome
      if (checkErrorMsg != null) {
        _errorMessage = checkErrorMsg;
        _canCreate = false;
      } else if (exists) {
        _errorMessage = AppLocalizations.of(context)!.dictionaryAlreadyExists;
        _canCreate = false; // Prevent creation if name exists
      } else {
        // No errors, proceed with creation
        _errorMessage = null;
        _canCreate = true; // Ensure create is enabled if validation passed
        widget.onCreate(dictionaryName, _selectedColor, _selectedType);
        Navigator.of(context).pop(); // Close dialog on success
      }
    });
  }

  void _validateName() {
    final text = _textController.text.trim();
    final isNotEmpty = text.isNotEmpty;
    // Only update state if canCreate status changes OR if there's an error to clear
    final bool needsStateUpdate =
        (isNotEmpty != _canCreate) || (_errorMessage != null);

    if (needsStateUpdate) {
      setState(() {
        _canCreate = isNotEmpty;
        _errorMessage = null; // Clear previous errors on text change
      });
    }
  }
}
