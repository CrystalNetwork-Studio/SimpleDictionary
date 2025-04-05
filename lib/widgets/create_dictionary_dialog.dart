import 'package:flutter/material.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

class CreateDictionaryDialog extends StatefulWidget {
  final Function(String, Color) onCreate;
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
              onSubmitted:
                  (_canCreate && !_isLoading) ? (_) => _submit() : null,
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
                                              .withValues(alpha: 0.9),
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
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final text = _textController.text.trim();
      final isNotEmpty = text.isNotEmpty;
      final bool needsStateUpdate =
          (isNotEmpty != _canCreate) || (_errorMessage != null);

      if (needsStateUpdate) {
        setState(() {
          _canCreate = isNotEmpty;
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _submit() async {
    final dictionaryName = _textController.text.trim();
    if (dictionaryName.isEmpty || _isLoading) return;

    if (mounted) setState(() => _isLoading = true);

    bool exists = false;
    String? checkErrorMsg;
    try {
      exists = await widget.dictionaryExists(dictionaryName);
    } catch (e) {
      // Consider using a logging framework here instead of print
      print('Error checking dictionary existence: $e');
      checkErrorMsg = AppLocalizations.of(context)!.errorValidatingNameDialog;
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
        widget.onCreate(dictionaryName, _selectedColor);
        Navigator.of(context).pop();
      }
    });
  }
}
