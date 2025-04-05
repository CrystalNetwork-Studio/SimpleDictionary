import 'package:flutter/material.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String dictionaryName;

  const ConfirmDeleteDialog({required this.dictionaryName, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localization = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(localization.deleteDictionary),
      content: Text(localization.deleteDictionaryConfirmation(dictionaryName)),
      actionsPadding: const EdgeInsets.only(right: 16.0, bottom: 12.0),
      actions: <Widget>[
        TextButton(
          child: Text(localization.cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(localization.delete),
        ),
      ],
    );
  }
}
