import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/filter.dart';
import 'search_query.dart';

final sauceFilterProvider = NotifierProvider<SauceFilterNotifier, SauceFilter>(
  SauceFilterNotifier.new,
);

class SauceFilterNotifier extends Notifier<SauceFilter> {
  @override
  SauceFilter build() {
    // listen(subscribe) to changes in query
    ref.listen(searchQueryProvider, (previous, next) {
      final newFilter = ref.read(queryParserProvider).parse(next);
      if (state != newFilter) state = newFilter;
    });
    // initial state when first created
    final init = ref.read(searchQueryProvider);
    return ref.read(queryParserProvider).parse(init);
  }

  void updateFilter(SauceFilter filter) {
    if (filter == state) return;
    state = filter;
  }
}
