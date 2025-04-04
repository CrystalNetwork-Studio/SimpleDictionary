import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dictionary_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/create_dictionary_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dictionaryProvider = Provider.of<DictionaryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Мої словники')),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => dictionaryProvider.loadDictionaries(),
        child: Builder(
          builder: (context) {
            if (dictionaryProvider.isLoading &&
                dictionaryProvider.dictionaries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (dictionaryProvider.dictionaries.isEmpty) {
              return LayoutBuilder(
                builder:
                    (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const EmptyState(),
                      ),
                    ),
              );
            } else {
              return DictionaryList(
                dictionaries: dictionaryProvider.dictionaries,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Provider.of<DictionaryProvider>(context, listen: false).clearError();

          await showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              final provider = Provider.of<DictionaryProvider>(
                dialogContext,
                listen: false,
              );
              return CreateDictionaryDialog(
                onCreate: (name, color) {
                  provider.addDictionary(name, color: color).then((success) {
                    if (!success && dialogContext.mounted) {
                      final error =
                          provider.error ?? 'Не вдалося створити словник.';
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      provider.clearError();
                    }
                  });
                },
                dictionaryExists: (String name) async {
                  return await provider.dictionaryExists(name);
                },
              );
            },
          );
        },
        tooltip: 'Додати словник',
        child: const Icon(Icons.add),
      ),
    );
  }
}
