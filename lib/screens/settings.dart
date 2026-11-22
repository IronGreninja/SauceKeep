import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              bottom: 8,
            ),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            elevation: 0,
            color: colors.surfaceContainerLow,
            child: ListTile(
              leading: Icon(
                Icons.palette_outlined,
                color: colors.primary,
              ),

              title: const Text('Theme'),

              subtitle: Text(
                switch (currentTheme) {
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                  ThemeMode.system => 'System default',
                },
              ),

              trailing: DropdownButton<ThemeMode>(
                value: currentTheme,
                underline: const SizedBox(),

                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],

                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    ref.read(themeProvider.notifier).setTheme(mode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
