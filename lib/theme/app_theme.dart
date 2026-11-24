import 'package:material_ui/material_ui.dart';

class SeedColorSwatch {
  final String name;
  final Color color;
  const SeedColorSwatch(this.name, this.color);
}

const appSwatches = [
  SeedColorSwatch('Indigo', Color(0xFF3F51B5)),
  SeedColorSwatch('Teal', Color(0xFF00897B)),
  SeedColorSwatch('Emerald', Color(0xFF2E7D32)),
  SeedColorSwatch('Amber', Color(0xFFEF6C00)),
  SeedColorSwatch('Crimson', Color(0xFFC62828)),
  SeedColorSwatch('Plum', Color(0xFF7B1FA2)),
  SeedColorSwatch('Slate', Color(0xFF546E7A)),
];
