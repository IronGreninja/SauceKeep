import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/add_dialog.dart';
import 'home/card.dart';
import '../state.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    // final currentSauceItems = ref.watch(allSauceProvider);
    final filteredSauceItems = ref.watch(filteredSauceItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SauceKeep'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                // Updates query state instantly as the user types
                ref.read(searchQueryProvider.notifier).updateQuery(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search (e.g. tag:a -tag:b title:"abc")...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            tooltip: 'Filter',
            onPressed: () {}, // todo: popup gui to add query str in search TextField below it
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const SauceAddDialog(),
        ),
        tooltip: 'New',
        child: const Icon(Icons.add),
      ),
      body: filteredSauceItems.when(
        data: (sauceItems) {
          return ListView.builder(
            itemCount: sauceItems.length,
            itemBuilder: (context, index) =>
                SauceCard(sauce: sauceItems[index]),
          );
        },
        error: (e, s) {
          debugPrintStack(label: e.toString(), stackTrace: s);
          return const Text('An error has occured');
        },
        loading: () => const Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
