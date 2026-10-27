import 'package:drift/drift.dart';

@DataClassName('Sauce')
class SauceItems extends Table with AutoIncrementingPrimaryKey {
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table with AutoIncrementingPrimaryKey {
  TextColumn get name => text().unique()();

  static List<String> namesListFromCommaSepStrOfNames(String tags) {
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

class SauceTags extends Table {
  IntColumn get sauceId => integer().references(SauceItems, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column<Object>> get primaryKey => {sauceId, tagId};
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
