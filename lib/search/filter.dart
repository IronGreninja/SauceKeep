import 'package:collection/collection.dart';

class SauceFilter {
  final Set<String> includeTags;
  final Set<String> excludeTags;
  final String title;
  final String desc;

  const SauceFilter({
    required this.includeTags,
    required this.excludeTags,
    required this.title,
    required this.desc,
  });

  SauceFilter copyWith({
    Set<String>? includeTags,
    Set<String>? excludeTags,
    String? title,
    String? desc,
  }) {
    return SauceFilter(
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
      title: title ?? this.title,
      desc: desc ?? this.desc,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    const setEq = SetEquality<String>();
    return other is SauceFilter &&
        other.title == title &&
        other.desc == desc &&
        setEq.equals(other.includeTags, includeTags) &&
        setEq.equals(other.excludeTags, excludeTags);
  }

  @override
  int get hashCode {
    const setEq = SetEquality<String>();
    return Object.hash(
      setEq.hash(includeTags),
      setEq.hash(excludeTags),
      title,
      desc,
    );
  }
}
