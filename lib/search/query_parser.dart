import 'filter.dart';

abstract class QueryParser {
  SauceFilter parse(String query);
}

class SimpleQueryParser implements QueryParser {
  @override
  SauceFilter parse(String query) {
    var (include, exclude) = _parseTags(query);

    return SauceFilter(
      includeTags: include,
      excludeTags: exclude,
      title: _parseTitle(query),
      desc: _parseDesc(query),
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
    // Matches title:value or title:"multi word"

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
}
