import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sauce_filter.dart';
import 'database.dart';

final allSauceItemsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.allSauce();
});

final filteredSauceItemsProvider = StreamProvider.autoDispose((ref) {
  final filter = ref.watch(sauceFilterProvider);
  final database = ref.watch(databaseProvider);
  return database.watchFilteredSauceItems(filter);
});

final filteredSauceItemsWithTagsProvider = StreamProvider.autoDispose((ref) {
  final filter = ref.watch(sauceFilterProvider);
  final database = ref.watch(databaseProvider);
  return database.watchFilteredSauceItemsWithTags(filter);
});
