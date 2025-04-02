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
    // ignore: unused_local_variable
    final dictionaryProvider = Provider.of<DictionaryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Dictionary')),
      drawer: const AppDrawer(),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dictionaries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.dictionaries.isEmpty) {
            return const EmptyState();
          } else {
            return DictionaryList(dictionaries: provider.dictionaries);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return CreateDictionaryDialog(
                onCreate: (name) {
                  Provider.of<DictionaryProvider>(
                    context,
                    listen: false,
                  ).addDictionary(name);
                },
                dictionaryExists: (String name) async {
                  return await Provider.of<DictionaryProvider>(
                    context,
                    listen: false,
                  ).dictionaryExists(name);
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
