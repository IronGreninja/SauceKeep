import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/extensions/fts5.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/filter.dart';

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

  Future<int> tryCreateTag(String name) {
    name = name.trim();

    return transaction(() async {
      final int tagId;

      // Check if the tag already exists
      final tag = await (select(
        tags,
      )..where((t) => t.name.equals(name))).getSingleOrNull();

      if (tag != null) {
        // Tag exists, use its id
        tagId = tag.id;
      } else {
        // Tag doesn't exist, insert it and get the new id
        tagId = await into(tags).insert(
          TagsCompanion.insert(name: name),
        );
      }

      return tagId;
    });
  }

  Future<int> createSauceWithTags({
    int? id,
    required String title,
    String? desc,
    required List<String> tagNames, // todo: make this a set
    DateTime? created,
  }) {
    return transaction(() async {
      // Insert Sauce and get the id
      final Value<String> descValue = desc != null
          ? Value(desc)
          : const Value.absent();
      final Value<DateTime> createdValue = created != null
          ? Value(created)
          : const Value.absent();
      final int sauceId;
      if (id == null) {
        sauceId = await into(sauceItems).insert(
          SauceItemsCompanion.insert(
            title: title,
            description: descValue,
          ),
        );
      } else {
        sauceId = id;
        await into(sauceItems).insert(
          SauceItemsCompanion.insert(
            id: Value(sauceId),
            title: title,
            description: descValue,
            createdAt: createdValue,
          ),
        );
      }

      // Process each tag name
      for (final tagName in tagNames) {
        final trimmedName = tagName.trim();
        if (trimmedName.isEmpty) continue;

        // insert new or get existing tag id
        final tagId = await tryCreateTag(trimmedName);

        // Link the sauce and tag
        await into(sauceTags).insert(
          SauceTagsCompanion.insert(tagId: tagId, sauceId: sauceId),
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
      // Update the sauce item
      await (update(sauceItems)..where((s) => s.id.equals(sauceId))).write(
        SauceItemsCompanion(
          title: Value(title),
          description: desc != null ? Value(desc) : const Value.absent(),
        ),
      );

      // Remove existing tag associations for this sauce
      await (delete(sauceTags)..where((st) => st.sauceId.equals(sauceId))).go();

      // Insert/find new tags and link them
      for (final tagName in tagNames) {
        final trimmedName = tagName.trim();
        if (trimmedName.isEmpty) continue;

        final tagId = await tryCreateTag(trimmedName);

        await into(sauceTags).insert(
          SauceTagsCompanion.insert(
            sauceId: sauceId,
            tagId: tagId,
          ),
        );
      }
    });
  }

  Future<void> deleteSauceWithCleanup(int sauceId) {
    return transaction(() async {
      // Delete the sauce itself
      await (delete(sauceItems)..where((s) => s.id.equals(sauceId))).go();

      // Associated sauceTags entries are deleted due to cascade

      // Clean up any tags left without associated sauce // todo: create a trigger for this?
      final usedTagIds = selectOnly(sauceTags)..addColumns([sauceTags.tagId]);
      await (delete(tags)..where((t) => t.id.isNotInQuery(usedTagIds))).go();
    });
  }

  Stream<List<Sauce>> watchFilteredSauceItems(SauceFilter filter) {
    final query = _filterSauceItems(filter);
    return query.watch();
  }

  SimpleSelectStatement<$SauceItemsTable, Sauce> _filterSauceItems(
    SauceFilter filter,
  ) {
    // Start with a base select statement on the sauceItems table
    final query = select(sauceItems); // select * from sauceItems

    // Filter by created
    final createdFilter = filter.created;
    switch (createdFilter.type) {
      case .before:
        query.where((s) => s.createdAt.isSmallerThanValue(createdFilter.to!));
      case .after:
        query.where((s) => s.createdAt.isBiggerThanValue(createdFilter.from!));
      case .between:
        query.where(
          (s) => s.createdAt.isBetweenValues(
            createdFilter.from!,
            createdFilter.to!,
          ),
        );
      case .none:
    }

    //  Filter by title if specified
    if (filter.title.isNotEmpty) {
      final ftsTitleQuery = 'title : ${filter.title}';
      final ftsSelectQuery = (selectOnly(sauceFts)
        ..addColumns([sauceFts.rowId])
        ..where(sauceFts.match(ftsTitleQuery)));
      query.where((s) => s.id.isInQuery(ftsSelectQuery));
    }

    //  Filter by description if specified
    if (filter.desc.isNotEmpty) {
      final ftsDescQuery = 'description : ${filter.desc}';
      final ftsSelectQuery = (selectOnly(sauceFts)
        ..addColumns([sauceFts.rowId])
        ..where(sauceFts.match(ftsDescQuery)));
      query.where((s) => s.id.isInQuery(ftsSelectQuery));
    }

    //  Include Tags: Sauce MUST have them all
    for (final tagName in filter.includeTags) {
      query.where((s) {
        // inner query whose output contains exactly one row (= s.id) if s is associated with tagName
        final matchingTag =
            selectOnly(sauceTags) // 2. from sauceTags st
                .join([
                  innerJoin(tags, tags.id.equalsExp(sauceTags.tagId)),
                ]) // 3. inner join tags t on t.id = st.tagId
              ..addColumns([sauceTags.sauceId]) // 1. select st.sauceId
              ..where(
                sauceTags.sauceId.equalsExp(s.id) &
                    tags.name.equals(
                      tagName,
                    ), // 4. where st.sauceId = s.id and t.name = tagName
              );

        return existsQuery(
          matchingTag,
        ); // where exists (output from matchingTag)
      });
    }

    // Exclude Tags: Sauce MUST NOT have any of these
    if (filter.excludeTags.isNotEmpty) {
      query.where((s) {
        // inner query whose output is not empty & contains n rows
        // if s is associated with n tags in excludeTags. all rows are = s.id
        // Using selectOnly(..., distinct: true) uses 'select distinct' and returns only one row = s.id
        final matchingTag =
            selectOnly(sauceTags)
                .join([innerJoin(tags, tags.id.equalsExp(sauceTags.tagId))])
              ..addColumns([sauceTags.sauceId])
              ..where(
                sauceTags.sauceId.equalsExp(s.id) &
                    tags.name.isIn(filter.excludeTags),
              );
        return notExistsQuery(matchingTag);
      });
    }

    // Order by created_at
    query.orderBy([
      (si) => .new(expression: si.createdAt, mode: .desc),
    ]); // latest first // todo: allow user to choose

    return query;
  }

  Stream<List<SauceWithTags>> watchFilteredSauceItemsWithTags(
    SauceFilter filter,
  ) {
    final query = _filterSauceItems(filter);
    return query
        .join([
          leftOuterJoin(sauceTags, sauceTags.sauceId.equalsExp(sauceItems.id)),
          leftOuterJoin(tags, tags.id.equalsExp(sauceTags.tagId)),
        ])
        .watch()
        .map((rows) {
          final Map<int, SauceWithTags> result = {};
          for (final row in rows) {
            // always add the sauce first, its columns will never be null
            final sauce = row.readTable(sauceItems);
            result.putIfAbsent(
              sauce.id,
              () => SauceWithTags(sauce: sauce, tags: []),
            );
            // sauce may have no tags, so the columns of tags table will be null
            // (since it is right of a left outer join)
            final tag = row.readTableOrNull(tags);
            if (tag == null) continue;
            result[sauce.id]!.tags.add(tag.name);
          }
          return result.values.toList();
        });
  }
}

class SauceWithTags {
  final Sauce sauce;
  final List<String> tags;

  SauceWithTags({
    required this.sauce,
    required this.tags,
  });
}
