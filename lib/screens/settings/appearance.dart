import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../../providers/theme.dart';

class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider.select((t) => t.themeMode));
    final useDynamicColor = ref.watch(
      themeProvider.select((t) => t.useDynamicColor),
    );
    final seedColor = ref.watch(
      themeProvider.select((t) => t.seedColor),
    );
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('Theme mode'),
              trailing: SegmentedButton<ThemeMode>(
                segments: [
                  .new(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    tooltip: 'Follow System',
                  ),
                  .new(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    tooltip: 'Light',
                  ),
                  .new(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    tooltip: 'Dark',
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (newMode) {
                  ref.read(themeProvider.notifier).setMode(newMode.first);
                },
                showSelectedIcon: false,
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              // secondary: const Icon(Icons.auto_awesome),
              title: const Text('Use Material You'),
              subtitle: const Text(
                'Adapt colors from system wallpaper/accent when supported',
              ),
              value: useDynamicColor,
              onChanged: (value) =>
                  ref.read(themeProvider.notifier).setUseDynamicColor(value),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Color'),
              trailing: ColorIndicator(
                // todo
                borderRadius: 20,
                color: seedColor,
                onSelectFocus: false,
                onSelect: () async {
                  // Wait for the dialog to return color selection result.
                  // final Color newColor = await showColorPickerDialog( // fixme: error here
                  //   // The dialog needs a context, we pass it in.
                  //   context,
                  //   // starting color.
                  //   seedColor,
                  //   title: Text(
                  //     'ColorPicker',
                  //     style: Theme.of(context).textTheme.titleLarge,
                  //   ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
