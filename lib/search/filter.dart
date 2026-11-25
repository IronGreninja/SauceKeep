import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class DateRange {
  final DateTime from;
  final DateTime to;

  const DateRange({required this.from, required this.to});
}

@immutable
class SauceFilter {
  final Set<String> includeTags;
  final Set<String> excludeTags;
  final String title;
  final String desc;
  final DateRange created;

  const SauceFilter({
    this.includeTags = const {},
    this.excludeTags = const {},
    this.title = '',
    this.desc = '',
    required this.created,
  });

  SauceFilter copyWith({
    Set<String>? includeTags,
    Set<String>? excludeTags,
    String? title,
    String? desc,
    DateRange? created,
  }) {
    return SauceFilter(
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      created: created ?? this.created,
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
        setEq.equals(other.excludeTags, excludeTags) &&
        other.created == created;
  }

  @override
  int get hashCode {
    const setEq = SetEquality<String>();
    return Object.hash(
      setEq.hash(includeTags),
      setEq.hash(excludeTags),
      title,
      desc,
      created,
    );
  }
}
