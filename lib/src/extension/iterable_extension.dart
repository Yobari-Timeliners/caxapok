import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

typedef IndexedValue<T> = ({int index, T value});

const _deepCollectionEquality = DeepCollectionEquality();

extension IterableExtension<T> on Iterable<T> {
  /// Get the first value [T] satisfying the predicate [test] with its index.
  ///
  /// If no value is found, returns `null`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final result = list.firstIndexedWhereOrNull((e) => e > 2);
  /// print(result); // (index: 2, value: 3)
  ///
  /// final notFound = list.firstIndexedWhereOrNull((e) => e > 10);
  /// print(notFound); // null
  /// ```
  IndexedValue<T>? firstIndexedWhereOrNull(bool Function(T element) test) {
    final result = indexed.firstWhereOrNull((e) => test(e.$2));

    if (result == null) return null;

    return (index: result.$1, value: result.$2);
  }

  /// Get the last value [T] satisfying the predicate [test] with its index.
  ///
  /// If no value is found, returns `null`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// final result = list.lastIndexedWhereOrNull((e) => e < 4);
  /// print(result); // (index: 2, value: 3)
  ///
  /// final notFound = list.lastIndexedWhereOrNull((e) => e > 10);
  /// print(notFound); // null
  /// ```
  IndexedValue<T>? lastIndexedWhereOrNull(bool Function(T element) test) {
    final result = indexed.lastWhereOrNull((e) => test(e.$2));

    if (result == null) return null;

    return (index: result.$1, value: result.$2);
  }

  /// Get the difference between two [Iterable]s.
  ///
  /// ### The difference is calculated relative to [other], example:
  ///
  /// ```dart
  /// const list1 = [
  ///   _Stub(id: 1, name: '1'),
  ///   _Stub(id: 2, name: '2'),
  ///   _Stub(id: 4, name: '4'),
  /// ];
  /// const list2 = [
  ///   _Stub(id: 1, name: '1'),
  ///   _Stub(id: 3, name: '3'),
  ///   _Stub(id: 4, name: '5'),
  /// ];
  ///
  /// final difference = list2.difference(
  ///   other: list1,
  ///   equals: (p0, p1) => p0.id == p1.id,
  ///   hashCode: (item) => item.id.hashCode,
  /// );
  ///
  /// print(difference); // {removed: [_Stub(id: 2, name: '2')], added: [_Stub(id: 3, name: '3')], updated: [_Stub(id: 4, name: '5')]}
  /// ```
  ///
  /// Calculations are performed using [LinkedHashSet], therefore:
  ///
  /// * [equals] - element comparison function, defaults to the standard [Object.==].
  /// * [hashCode] - element hash calculation function, defaults to the standard [Object.hashCode].
  /// * [includeUpdatedWhen] - element comparison function for detecting updates, defaults to the
  /// standard [Object.==]. Called when elements are neither removed nor added but remain in the
  /// list and may have changed.
  IterableDifference<T> difference(
    Iterable<T> other, {
    bool Function(T, T)? equals,
    int Function(T item)? hashCode,
    bool Function(T current, T previous)? includeUpdatedWhen,
  }) {
    final otherSet = LinkedHashSet<T>(equals: equals, hashCode: hashCode)..addAll(other);
    final set = LinkedHashSet<T>(equals: equals, hashCode: hashCode)..addAll(this);

    final removed = <T>[];
    final added = <T>[];
    final updated = <IterableUpdate<T>>[];

    for (final item in set) {
      final otherItem = otherSet.lookup(item);

      if (otherItem == null) {
        added.add(item);
        continue;
      }

      final willIncludeUpdated = includeUpdatedWhen?.call(item, otherItem) ?? (item != otherItem);

      if (!willIncludeUpdated) {
        continue;
      }

      updated.add(.new(old: otherItem, updated: item));
    }

    for (final item in otherSet) {
      if (set.contains(item)) {
        continue;
      }

      removed.add(item);
    }

    return .new(
      removed: removed,
      added: added,
      updated: updated,
      actual: this,
    );
  }

  /// Similar to [difference], but with indexing.
  ///
  /// Will be slower than [difference] on large amounts of data.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list1 = [1, 2, 3, 4];
  /// final list2 = [1, 5, 3, 6];
  ///
  /// final changes = list2.indexedDifference(other: list1);
  /// print(changes.removed); // [IterableIndexedRemove(data: 2, index: 1), IterableIndexedRemove(data: 4, index: 3)]
  /// print(changes.added); // [IterableIndexedInsert(data: 5, index: 1), IterableIndexedInsert(data: 6, index: 3)]
  /// ```
  IterableIndexedDifference<T> indexedDifference(
    Iterable<T> other, {
    bool Function(T, T)? equals,
    int Function(T item)? hashCode,
    bool Function(T item, T other)? includeUpdatedWhen,
  }) {
    final otherMap = HashMap<T, IndexedValue<T>>(equals: equals, hashCode: hashCode);
    final thisMap = HashMap<T, IndexedValue<T>>(equals: equals, hashCode: hashCode);

    // Use indexed instead of manual iteration
    for (final (index, item) in other.indexed) {
      otherMap[item] = (index: index, value: item);
    }

    for (final (index, item) in indexed) {
      thisMap[item] = (index: index, value: item);
    }

    final removed = <IterableIndexedRemove<T>>[];
    final added = <IterableIndexedInsert<T>>[];
    final updated = <IterableIndexedUpdate<T>>[];

    for (final entry in thisMap.entries) {
      final otherItem = otherMap[entry.key];

      if (otherItem == null) {
        added.add(.new(data: entry.key, index: entry.value.index));
        continue;
      }

      final willIncludeUpdated =
          includeUpdatedWhen?.call(entry.value.value, otherItem.value) ??
          (entry.value.value != otherItem.value);

      if (willIncludeUpdated) {
        updated.add(
          .new(
            old: otherItem,
            updated: entry.value,
          ),
        );
      }
    }

    for (final entry in otherMap.entries) {
      if (thisMap.containsKey(entry.key)) {
        continue;
      }

      removed.add(
        .new(data: entry.key, index: entry.value.index),
      );
    }

    return .new(
      removed: removed,
      added: added,
      updated: updated,
      actual: this,
    );
  }
}

/// Difference between two [Iterable]s.
///
/// See [IterableExtension.difference] for more details.
@immutable
class IterableDifference<T> {
  final Iterable<T> removed;
  final Iterable<T> added;
  final Iterable<IterableUpdate<T>> updated;
  final Iterable<T> actual;

  const IterableDifference({
    required this.removed,
    required this.added,
    required this.updated,
    required this.actual,
  });

  bool get hasDifference => hasAdded || hasRemoved || hasUpdated;

  bool get hasRemoved => removed.isNotEmpty;

  bool get hasAdded => added.isNotEmpty;

  bool get hasUpdated => updated.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IterableDifference<T>) return false;

    return _deepCollectionEquality.equals(removed, other.removed) &&
        _deepCollectionEquality.equals(added, other.added) &&
        _deepCollectionEquality.equals(updated, other.updated) &&
        _deepCollectionEquality.equals(actual, other.actual);
  }

  @override
  int get hashCode => Object.hash(
    _deepCollectionEquality.hash(removed),
    _deepCollectionEquality.hash(added),
    _deepCollectionEquality.hash(updated),
    _deepCollectionEquality.hash(actual),
  );
}

/// Indexed difference between two [Iterable]s.
///
/// See [IterableExtension.indexedDifference] for more details.
@immutable
class IterableIndexedDifference<T> {
  final Iterable<IterableIndexedRemove<T>> removed;
  final Iterable<IterableIndexedInsert<T>> added;
  final Iterable<IterableIndexedUpdate<T>> updated;
  final Iterable<T> actual;

  const IterableIndexedDifference({
    required this.removed,
    required this.added,
    required this.updated,
    required this.actual,
  });

  bool get hasDifference => hasAdded || hasRemoved || hasUpdated;

  bool get hasRemoved => removed.isNotEmpty;

  bool get hasAdded => added.isNotEmpty;

  bool get hasUpdated => updated.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IterableIndexedDifference<T>) return false;

    return _deepCollectionEquality.equals(removed, other.removed) &&
        _deepCollectionEquality.equals(added, other.added) &&
        _deepCollectionEquality.equals(updated, other.updated) &&
        _deepCollectionEquality.equals(actual, other.actual);
  }

  @override
  int get hashCode => Object.hash(
    _deepCollectionEquality.hash(removed),
    _deepCollectionEquality.hash(added),
    _deepCollectionEquality.hash(updated),
    _deepCollectionEquality.hash(actual),
  );
}

@immutable
final class IterableUpdate<T> {
  final T old;
  final T updated;

  const IterableUpdate({
    required this.old,
    required this.updated,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IterableUpdate<T>) return false;

    return _deepCollectionEquality.equals(old, other.old) &&
        _deepCollectionEquality.equals(updated, other.updated);
  }

  @override
  int get hashCode => Object.hash(
    _deepCollectionEquality.hash(old),
    _deepCollectionEquality.hash(updated),
  );
}

final class IterableIndexedRemove<T> {
  final T data;

  final int index;

  const IterableIndexedRemove({
    required this.data,
    required this.index,
  });
}

final class IterableIndexedInsert<T> {
  final T data;

  final int index;

  const IterableIndexedInsert({required this.data, required this.index});
}

final class IterableIndexedUpdate<T> {
  final IndexedValue<T> old;
  final IndexedValue<T> updated;

  IterableIndexedUpdate({
    required this.old,
    required this.updated,
  });

  int get index => updated.index;
}
