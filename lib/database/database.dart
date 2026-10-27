import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/query_parser.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [SauceItems, Tags, SauceTags], include: {'sql.drift'})
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 1;

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'sauce_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static final provider = Provider((ref) {
    final database = AppDatabase();
    ref.onDispose(database.close);

    return database;
  });

  Stream<List<Sauce>> allSauce() {
    final query = select(sauceItems);
    return query.watch();
  }

  Future<int> createSauceWithTags({
    int? id,
    required String title,
    String? desc,
    required List<String> tagNames,
  }) {
    return transaction(() async {
      // Insert Sauce and get the id
      final int sauceId;
      if (id == null) {
        sauceId = await into(sauceItems).insert(
          SauceItemsCompanion.insert(
            title: title,
            description: Value(desc),
          ),
        );
      } else {
        sauceId = id;
        await into(sauceItems).insert(
          SauceItemsCompanion.insert(
            id: Value(sauceId),
            title: title,
            description: Value(desc),
          ),
        );
      }

      // Process each tag name
      for (final tagName in tagNames) {
        final trimmedName = tagName.trim();
        if (trimmedName.isEmpty) continue;

        // Check if the tag already exists
        var tag = await (select(
          tags,
        )..where((t) => t.name.equals(trimmedName))).getSingleOrNull();

        int tagId;
        if (tag != null) {
          // Tag exists, use its id
          tagId = tag.id;
        } else {
          // Tag doesn't exist, insert it and get the new id
          tagId = await into(tags).insert(
            TagsCompanion.insert(name: trimmedName),
          );
        }

        // Link the sauce and tag
        await into(sauceTags).insert(
          SauceTagsCompanion.insert(tagId: tagId, sauceId: sauceId),
          mode: InsertMode.insertOrIgnore, // no error when tag already exists
        );
      }

      return sauceId;
    });
  }

  Future<List<String>> getSauceTags(int sauceId) {
    // Fetch tags linked to sauceId
    final query = select(tags).join([
      innerJoin(
        sauceTags,
        sauceTags.tagId.equalsExp(tags.id),
      ),
    ])..where(sauceTags.sauceId.equals(sauceId));

    final Future<List<String>> fetchedTags = query
        .map((row) => row.read(tags.name)!)
        .get();
    return fetchedTags;
  }

  Future<void> updateSauceWithTags({
    required int sauceId,
    required String title,
    String? desc,
    required List<String> tagNames,
  }) {
    return transaction(() async {
      // Update the sauce record
      await (update(sauceItems)..where((s) => s.id.equals(sauceId))).write(
        SauceItemsCompanion(
          title: Value(title),
          description: Value(desc),
        ),
      );

      // Remove existing tag associations for this sauce
      await (delete(sauceTags)..where((st) => st.sauceId.equals(sauceId))).go();

      // Insert/find new tags and link them
      for (final tagName in tagNames) {
        final trimmedName = tagName.trim();
        if (trimmedName.isEmpty) continue;

        var tag = await (select(
          tags,
        )..where((t) => t.name.equals(trimmedName))).getSingleOrNull();

        int tagId;
        if (tag != null) {
          tagId = tag.id;
        } else {
          tagId = await into(tags).insert(
            TagsCompanion.insert(name: trimmedName),
          );
        }

        await into(sauceTags).insert(
          SauceTagsCompanion.insert(
            sauceId: sauceId,
            tagId: tagId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> deleteSauceWithCleanup(int sauceId) {
    return transaction(() async {
      // Delete associated sauceTags entries
      await (delete(sauceTags)..where((st) => st.sauceId.equals(sauceId))).go();

      // Delete the sauce itself
      await (delete(sauceItems)..where((s) => s.id.equals(sauceId))).go();

      // Clean up any tags left without associated sauce
      final usedTagIds = selectOnly(sauceTags)..addColumns([sauceTags.tagId]);
      await (delete(tags)..where((t) => t.id.isNotInQuery(usedTagIds))).go();
    });
  }

  Stream<List<Sauce>> watchFilteredSauceItems(String rawQuery) {
    final filter = ParsedSearchQuery.parse(rawQuery);

    // Start with a base select statement on the sauceItems table
    final query = select(sauceItems);

    //  Filter by title if specified
    if (filter.titleQuery != null && filter.titleQuery!.isNotEmpty) {
      query.where((s) => s.title.like('%${filter.titleQuery}%'));
    }

    //  Filter by description if specified
    if (filter.descQuery != null && filter.descQuery!.isNotEmpty) {
      query.where((s) => s.description.like('%${filter.descQuery}%'));
    }

    //  Include Tags: Sauce MUST have this tag
    for (final tagName in filter.includeTags) {
      final hasTag =
          selectOnly(sauceTags).join([
              innerJoin(tags, tags.id.equalsExp(sauceTags.tagId)),
            ])
            ..addColumns([sauceTags.sauceId])
            ..where(
              sauceTags.sauceId.equalsExp(sauceItems.id) &
                  tags.name.equals(tagName),
            );

      query.where((t) => existsQuery(hasTag));
    }

    // Exclude Tags: Sauce MUST NOT have any of these tags
    if (filter.excludeTags.isNotEmpty) {
      final hasExcludedTag =
          selectOnly(sauceTags).join([
              innerJoin(tags, tags.id.equalsExp(sauceTags.tagId)),
            ])
            ..addColumns([sauceTags.sauceId])
            ..where(
              sauceTags.sauceId.equalsExp(sauceItems.id) &
                  tags.name.isIn(filter.excludeTags),
            );

      query.where((t) => notExistsQuery(hasExcludedTag));
    }

    return query.watch();
  }
}
