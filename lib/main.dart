import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/home.dart';
import 'screens/settings.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  MainApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'SauceKeep',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          typography: .material2018(),
        ),
        routerConfig: _router,
      ),
    );
  }
}
