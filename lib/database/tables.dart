import 'package:drift/drift.dart';

@DataClassName('Sauce')
@TableIndex(
  name: 'idx_sauce_items_created_at',
  columns: {#createdAt},
) // date range & chronological filtering
class SauceItems extends Table with AutoIncrementingPrimaryKey {
  late final TextColumn title = text().check(
    title.trim().length.isBiggerThanValue(0),
  )();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table with AutoIncrementingPrimaryKey {
  TextColumn get name =>
      text().customConstraint('NOT NULL COLLATE NOCASE UNIQUE')();

  static List<String> namesListFromCommaSepStrOfNames(String tags) {
    return tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

@TableIndex(name: 'idx_sauce_tags_tag_sauce', columns: {#tagId, #sauceId})
class SauceTags extends Table {
  IntColumn get sauceId =>
      integer().references(SauceItems, #id, onDelete: .cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: .cascade)();

  @override
  Set<Column<Object>> get primaryKey => {sauceId, tagId};
}

mixin AutoIncrementingPrimaryKey on Table {
  IntColumn get id => integer().autoIncrement()();
}
