import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferencesWithCache>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

abstract final class PrefsKeys {
  static const themeMode = 'theme.mode';
  static const themeSeedColor = 'theme.seedcolor';
  static const themeUseDynamic = 'theme.usedynamic';
  static const searchQuerySyntax = 'search.syntax';

  static const Set<String> allowList = {
    themeMode,
    themeSeedColor,
    themeUseDynamic,
    searchQuerySyntax,
  };
}

Future<SharedPreferencesWithCache> createSharedPrefsWithCache() {
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: PrefsKeys.allowList,
    ),
  );
}
