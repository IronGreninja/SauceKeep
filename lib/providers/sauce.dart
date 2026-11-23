import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_query.dart';
import 'sauce_filter.dart';
import '../database/database.dart';

final allSauceItemsProvider = StreamProvider((ref) {
  final database = ref.watch(AppDatabase.provider);
  return database.allSauce();
});

final filteredSauceItemsProvider = StreamProvider.autoDispose((ref) {
  final filter = ref.watch(sauceFilterProvider);
  final database = ref.watch(AppDatabase.provider);
  return database.watchFilteredSauceItems(filter);
});

final filteredSauceItemsWithTagsProvider = StreamProvider.autoDispose((ref) {
  final filter = ref.watch(sauceFilterProvider);
  final database = ref.watch(AppDatabase.provider);
  return database.watchFilteredSauceItemsWithTags(filter);
});
