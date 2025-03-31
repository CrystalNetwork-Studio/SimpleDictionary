import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons
                  .folder_off_outlined, // KMM used Filled.Folder, maybe off is better?
              size: 64,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'У вас ще немає жодного словника.',
              style: theme.textTheme.headlineSmall, // Similar to h6
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Натисніть кнопку \'+\', щоб створити свій перший.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
