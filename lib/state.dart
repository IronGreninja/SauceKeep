import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/database.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() {
    // Clean up the timer when the provider is disposed
    ref.onDispose(() => _debounceTimer?.cancel());
    return '';
  }

  void updateQuery(String query) {
    // Cancel the previous timer if the user keeps typing
    _debounceTimer?.cancel();

    // Wait for 300ms of inactivity before updating the state
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = query;
    });
  }
}

final allSauceProvider = StreamProvider((ref) {
  final database = ref.watch(AppDatabase.provider);
  return database.allSauce();
});

final filteredSauceItemsProvider = StreamProvider.autoDispose((ref) {
  final queryText = ref.watch(searchQueryProvider);
  final database = ref.watch(AppDatabase.provider);

  return database.watchFilteredSauceItems(queryText);
});
