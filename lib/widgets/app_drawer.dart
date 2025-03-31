// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final dictionaryCount =
        context.watch<DictionaryProvider>().dictionaries.length;

    return Drawer(
      child: Column(
        children: <Widget>[
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined, // Use outlined book
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Simple Dictionary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          // Info Items
          _DrawerInfoItem(
            icon: Icons.collections_bookmark_outlined, // Outlined
            text: 'Словники: $dictionaryCount',
          ),
          const _DrawerInfoItem(
            icon: Icons.language_outlined, // Outlined
            text: 'Мова: Українська', // Hardcoded
          ),
          const Divider(),
          // Nav Items
          ListTile(
            leading: Icon(
              Icons.settings_outlined, // Outlined
              color:
                  Theme.of(context).iconTheme.color, // Use default icon color
            ),
            title: const Text('Налаштування'),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                // Navigate to SettingsScreen
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline, // Use outline variant
              color:
                  Theme.of(context).iconTheme.color, // Use default icon color
            ),
            title: const Text('Про додаток'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Інформація про додаток ще не реалізована.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Spacer(), // Push version to bottom
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Версія 1.0.0', // TODO: Get version dynamically later
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper remains the same
class _DrawerInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DrawerInfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 24,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          const SizedBox(width: 16), // Increased spacing slightly
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
