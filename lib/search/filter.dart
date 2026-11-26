import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum DateRangeType { before, after, between, none }

@immutable
class DateRange {
  final DateRangeType type;
  final DateTime? from;
  final DateTime? to;

  const DateRange(this.type, {this.from, this.to});
}

enum OrderType { latest, oldest }

@immutable
class SauceFilter {
  final Set<String> includeTags;
  final Set<String> excludeTags;
  final String title;
  final String desc;
  final DateRange created;
  final OrderType order;

  const SauceFilter({
    this.includeTags = const {},
    this.excludeTags = const {},
    this.title = '',
    this.desc = '',
    this.created = const .new(.none),
    this.order = .latest,
  });

  SauceFilter copyWith({
    Set<String>? includeTags,
    Set<String>? excludeTags,
    String? title,
    String? desc,
    DateRange? created,
    OrderType? order,
  }) {
    return SauceFilter(
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      created: created ?? this.created,
      order: order ?? this.order,
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
        other.created == created &&
        other.order == order;
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
      order,
    );
  }
}
