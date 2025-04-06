import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../providers/dictionary_provider.dart';
import '../screens/about_app_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _appVersion = 'Loading...';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final dictionaryCount =
        context.watch<DictionaryProvider>().dictionaries.length;

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  localization.myDictionaries,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          _DrawerInfoItem(
            icon: Icons.collections_bookmark_outlined,
            text: localization.dictionariesCount(dictionaryCount),
          ),
          _DrawerInfoItem(
            icon: Icons.language_outlined,
            text: localization.languageDrawer,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(localization.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(localization.aboutApp),
            onTap: () {
              Navigator.pop(context);
              // Navigate to the AboutAppScreen instead of showing SnackBar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${localization.version} $_appVersion',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _appVersion = 'Failed to load';
        });
      }
      debugPrint('Error loading package info: $e');
    }
  }
}

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
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 16),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
