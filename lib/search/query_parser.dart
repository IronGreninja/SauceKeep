class ParsedSearchQuery {
  final List<String> includeTags = [];
  final List<String> excludeTags = [];
  String? titleQuery;
  String? descQuery;

  ParsedSearchQuery.parse(String input) {
    // Matches tag:value or tag:"multi word"
    final tagRegex = RegExp(r'(^|\s)tag:(?:"([^"]+)"|([^\s]+))');
    // Matches -tag:value or -tag:"multi word"
    final excludeTagRegex = RegExp(r'(^|\s)-tag:(?:"([^"]+)"|([^\s]+))');
    // Matches title:value or title:"multi word"
    final titleRegex = RegExp(r'(^|\s)title:(?:"([^"]+)"|([^\s]+))');
    // Matches desc:value or desc:"multi word"
    final descRegex = RegExp(r'(^|\s)desc:(?:"([^"]+)"|([^\s]+))');

    for (final m in tagRegex.allMatches(input)) {
      final val = m.group(2) ?? m.group(3);
      if (val != null) includeTags.add(val.trim());
    }
    for (final m in excludeTagRegex.allMatches(input)) {
      final val = m.group(2) ?? m.group(3);
      if (val != null) excludeTags.add(val.trim());
    }

    final tMatch = titleRegex.firstMatch(input);
    if (tMatch != null) {
      titleQuery = (tMatch.group(2) ?? tMatch.group(3))?.trim();
    }

    final dMatch = descRegex.firstMatch(input);
    if (dMatch != null) {
      descQuery = (dMatch.group(2) ?? dMatch.group(3))?.trim();
    }
  }

  @override
  String toString() {
    return 'include: {${includeTags.join(", ")}}\n'
        'exclude: {${excludeTags.join(", ")}}\n'
        'title: $titleQuery'
        '\ndesc: $descQuery';
  }
}
