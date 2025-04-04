import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String dictionaryName;

  const ConfirmDeleteDialog({required this.dictionaryName, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Видалити словник?'),
      content: Text(
        'Ви впевнені, що хочете видалити словник "$dictionaryName"? Цю дію неможливо скасувати.',
      ),
      actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 12.0),
      actions: <Widget>[
        TextButton(
          child: const Text('Скасувати'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          onPressed: () {
            Navigator.of(
              context,
            ).pop(true); // Return true if user confirms deletion.
          },
          child: const Text('Видалити'),
        ),
      ],
    );
  }
}
