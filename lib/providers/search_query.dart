import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/query_parser.dart';
import 'shared_preferences.dart';

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

final querySyntaxTypeProvider =
    NotifierProvider<QuerySyntaxTypeNotifier, QuerySyntaxType>(
      QuerySyntaxTypeNotifier.new,
    );

class QuerySyntaxTypeNotifier extends Notifier<QuerySyntaxType> {
  static const String _syntaxTypePrefKey = 'selected_query_syntax_type';

  @override
  QuerySyntaxType build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedKey = prefs.getString(_syntaxTypePrefKey);
    return QuerySyntaxType.fromKey(savedKey);
  }

  Future<void> setQuerySyntax(QuerySyntaxType type) async {
    if (state == type) return;
    state = type;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_syntaxTypePrefKey, type.key);
  }
}

final queryParserProvider = Provider((ref) {
  final selectedType = ref.watch(querySyntaxTypeProvider);
  return createQueryParser(selectedType);
});
