import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String _version = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Simple Dictionary',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.author),
            subtitle: const Text('Volodia Kraplich'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(l10n.company),
            subtitle: const Text('CrystalNetwork Studio'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.license),
            subtitle: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://github.com/CrystalNetwork-Studio/SimpleDictionary/blob/master/LICENSE',
                );
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
              },
              child: const Text('GNU GPLv3'),
            ),
            onTap: () async {
              final Uri url = Uri.parse(
                'https://github.com/CrystalNetwork-Studio/SimpleDictionary/blob/master/LICENSE',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw Exception('Could not launch $url');
              }
            },
            trailing: IconButton(
              icon: Icon(
                Icons.open_in_new,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://github.com/CrystalNetwork-Studio/SimpleDictionary/blob/master/LICENSE',
                );
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://github.com/CrystalNetwork-Studio/SimpleDictionary/releases',
                );
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
              },
              child: Text(_version.isNotEmpty ? _version : 'Loading...'),
            ),
            onTap: () async {
              final Uri url = Uri.parse(
                'https://github.com/CrystalNetwork-Studio/SimpleDictionary/releases',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw Exception('Could not launch $url');
              }
            },
            trailing: IconButton(
              icon: Icon(
                Icons.open_in_new,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://github.com/CrystalNetwork-Studio/SimpleDictionary/releases',
                );
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Text(
              l10n.aboutAppDescription,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'Error';
        });
      }
    }
  }
}
