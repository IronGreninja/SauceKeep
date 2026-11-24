import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'screens/home/home.dart';
import 'screens/settings/settings.dart';
import 'providers/shared_preferences.dart';
import 'providers/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load preferences before starting the app.
  final prefs = await createSharedPrefsWithCache();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: MainApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const HomePage(),
      routes: [
        GoRoute(path: 'settings', builder: (_, _) => const SettingsPage()),
      ],
    ),
  ],
);

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SauceKeep',
          theme: theme.getLightTheme(lightDynamic),
          darkTheme: theme.getDarkTheme(darkDynamic),
          themeMode: theme.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
