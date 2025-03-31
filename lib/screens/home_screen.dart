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
    // Access the provider

    // ignore: unused_local_variable
    final dictionaryProvider = Provider.of<DictionaryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Dictionary'),
        // Drawer icon is automatically added by Scaffold if drawer is present
      ),
      drawer: const AppDrawer(), // Add the drawer
      body: Consumer<DictionaryProvider>(
        // Use Consumer for rebuilds
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dictionaries.isEmpty) {
            // Show loading indicator only on initial load
            return const Center(child: CircularProgressIndicator());
          } else if (provider.dictionaries.isEmpty) {
            return const EmptyState(); // Show empty state if no dictionaries
          } else {
            // Show the list of dictionaries
            return DictionaryList(dictionaries: provider.dictionaries);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // Use dialogContext to avoid issues with context across async gaps
              return CreateDictionaryDialog(
                onCreate: (name) {
                  // Call provider's method to add dictionary
                  // Use read outside build methods for calls
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
