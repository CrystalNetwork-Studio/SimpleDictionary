import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String dictionaryName;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    required this.dictionaryName,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Видалити словник?'),
      content: Text(
        'Ви впевнені, що хочете видалити словник "$dictionaryName"? Цю дію неможливо скасувати.',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Скасувати'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor:
                colorScheme.error, // Use error color for delete button text
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Видалити'),
        ),
      ],
    );
  }
}
