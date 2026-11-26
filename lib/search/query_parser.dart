import 'filter.dart';

enum QuerySyntaxType {
  simple('simple'),
  advanced('advanced');

  const QuerySyntaxType(this.key);
  final String key;

  static QuerySyntaxType fromKey(String? key) {
    return QuerySyntaxType.values.firstWhere(
      (type) => type.key == key,
      orElse: () => QuerySyntaxType.simple,
    );
  }
}

abstract class QueryParser {
  String get syntaxType;
  SauceFilter parse(String query);
}

class SimpleQueryParser implements QueryParser {
  @override
  String get syntaxType => 'Simple';

  @override
  SauceFilter parse(String query) {
    var (include, exclude) = _parseTags(query);

    return SauceFilter(
      includeTags: include,
      excludeTags: exclude,
      title: _parseTitle(query),
      desc: _parseDesc(query),
      created: _parseCreated(query),
    );
  }

  String _parseTitle(String query) {
    // Matches title:value or title:"multi word"
    final titleRegex = RegExp(r'(^|\s)title:(?:"([^"]+)"|([^\s]+))');

    String? title;
    final tMatch = titleRegex.firstMatch(query);
    if (tMatch != null) {
      title = (tMatch.group(2) ?? tMatch.group(3))?.trim();
    }
    return title ?? '';
  }

  String _parseDesc(String query) {
    // Matches desc:value or desc:"multi word"
    final descRegex = RegExp(r'(^|\s)desc:(?:"([^"]+)"|([^\s]+))');

    String? desc;
    final dMatch = descRegex.firstMatch(query);
    if (dMatch != null) {
      desc = (dMatch.group(2) ?? dMatch.group(3))?.trim();
    }
    return desc ?? '';
  }

  (Set<String>, Set<String>) _parseTags(String query) {
    // Matches tag:value or tag:"multi word"
    final tagRegex = RegExp(r'(^|\s)tag:(?:"([^"]+)"|([^\s]+))');
    // Matches -tag:value or -tag:"multi word"
    final excludeTagRegex = RegExp(r'(^|\s)-tag:(?:"([^"]+)"|([^\s]+))');

    final Set<String> includeTags = {};
    final Set<String> excludeTags = {};

    for (final m in tagRegex.allMatches(query)) {
      final val = m.group(2) ?? m.group(3);
      if (val != null) includeTags.add(val.trim());
    }
    for (final m in excludeTagRegex.allMatches(query)) {
      final val = m.group(2) ?? m.group(3);
      if (val != null) excludeTags.add(val.trim());
    }

    return (includeTags, excludeTags);
  }

  DateRange _parseCreated(String query) {
    // Matches created:>2026-01-20 or created:<2026-04-15 or created:^2020-01-02,2021-01-02
    final createdRegex = RegExp(
      r'(?:^|\s)created:(?:(([<>])(\d{4}-\d{2}-\d{2}))|(?:\^(\d{4}-\d{2}-\d{2}),(\d{4}-\d{2}-\d{2})))',
    );

    DateRange result = .new(.none);

    final cMatch = createdRegex.firstMatch(query);
    if (cMatch != null) {
      if (cMatch.group(1) != null) {
        final date = DateTime.parse(cMatch.group(3)!);
        switch (cMatch.group(2)!) {
          case '<':
            result = .new(.before, to: date);
          case '>':
            result = .new(.after, from: date);
        }
      } else {
        var from = DateTime.parse(cMatch.group(4)!);
        var to = DateTime.parse(cMatch.group(5)!);

        if (from.isAfter(to)) (from, to) = (to, from);
        result = .new(.between, from: from, to: to);
      }
    }

    return result;
  }
}

class AdvancedQueryParser implements QueryParser {
  @override
  String get syntaxType => 'Advanced';

  @override
  SauceFilter parse(String query) {
    throw UnimplementedError();
  }
}

QueryParser createQueryParser(QuerySyntaxType type) {
  switch (type) {
    case QuerySyntaxType.simple:
      return SimpleQueryParser();
    case QuerySyntaxType.advanced:
      return AdvancedQueryParser();
  }
}
