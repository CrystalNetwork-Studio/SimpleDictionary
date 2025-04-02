import 'package:flutter/material.dart';

class CreateDictionaryDialog extends StatefulWidget {
  final Function(String) onCreate;
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

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final isNotEmpty = _textController.text.trim().isNotEmpty;
      if (isNotEmpty != _canCreate) {
        setState(() {
          _canCreate = isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Створити Словник'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Введіть назву для нового словника:'),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Назва словнику',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Відмінити'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _canCreate ? _submit : null,
          child: const Text('Створити'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_canCreate) {
      final dictionaryName = _textController.text.trim();
      final exists = await widget.dictionaryExists(dictionaryName);
      if (exists) {
        setState(() {
          _errorMessage = 'Словник з такою назвою вже існує.';
        });
      } else {
        if (!mounted) return;
        widget.onCreate(dictionaryName);
        Navigator.of(context).pop();
      }
    }
  }
}
