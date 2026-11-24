import 'package:material_ui/material_ui.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class SeedColor {
  final String name;
  final Color color;
  const SeedColor(this.name, this.color);
}

const standardSeedColors = [
  SeedColor('Indigo', Color(0xFF3F51B5)),
  SeedColor('Teal', Color(0xFF00897B)),
  SeedColor('Emerald', Color(0xFF2E7D32)),
  SeedColor('Amber', Color(0xFFEF6C00)),
  SeedColor('Crimson', Color(0xFFC62828)),
  SeedColor('Plum', Color(0xFF7B1FA2)),
  SeedColor('Slate', Color(0xFF546E7A)),
];

final standardSwatchMap = Map.fromEntries(
  standardSeedColors.map(
    (item) => MapEntry(
      ColorTools.createPrimarySwatch(item.color),
      item.name,
    ),
  ),
);
