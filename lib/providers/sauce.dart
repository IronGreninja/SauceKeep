import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_query.dart';
import '../database/database.dart';

final allSauceItemsProvider = StreamProvider((ref) {
  final database = ref.watch(AppDatabase.provider);
  return database.allSauce();
});

final filteredSauceItemsProvider = StreamProvider.autoDispose((ref) {
  final queryText = ref.watch(searchQueryProvider);
  final database = ref.watch(AppDatabase.provider);
  return database.watchFilteredSauceItems(queryText);
});

final filteredSauceItemsWithTagsProvider = StreamProvider.autoDispose((ref) {
  final queryText = ref.watch(searchQueryProvider);
  final database = ref.watch(AppDatabase.provider);
  return database.watchFilteredSauceItemsWithTags(queryText);
});
