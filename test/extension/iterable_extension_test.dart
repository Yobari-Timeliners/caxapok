import 'package:caxapok/src/extension/iterable_extension.dart';
import 'package:test/test.dart';

import '../stubs.dart';

void main() {
  group('firstIndexedWhereOrNull()', () {
    test('returns first element with index that matches predicate', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.firstIndexedWhereOrNull((e) => e > 2);

      expect(result, isNotNull);
      expect(result?.index, equals(2));
      expect(result?.value, equals(3));
    });

    test('returns null when no element matches predicate', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.firstIndexedWhereOrNull((e) => e > 10);

      expect(result, isNull);
    });

    test('returns first match when multiple elements satisfy predicate', () {
      const list = [1, 5, 8, 10, 15];

      final result = list.firstIndexedWhereOrNull((e) => e > 7);

      expect(result, isNotNull);
      expect(result?.index, equals(2));
      expect(result?.value, equals(8));
    });

    test('returns null for empty list', () {
      const list = <int>[];

      final result = list.firstIndexedWhereOrNull((e) => e > 0);

      expect(result, isNull);
    });

    test('returns first element if it matches', () {
      const list = [10, 5, 3, 2];

      final result = list.firstIndexedWhereOrNull((e) => e > 9);

      expect(result, isNotNull);
      expect(result?.index, equals(0));
      expect(result?.value, equals(10));
    });

    test('returns last element if only it matches', () {
      const list = [1, 2, 3, 4, 10];

      final result = list.firstIndexedWhereOrNull((e) => e > 9);

      expect(result, isNotNull);
      expect(result?.index, equals(4));
      expect(result?.value, equals(10));
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      final result = list.firstIndexedWhereOrNull((e) => e.id > 1);

      expect(result, isNotNull);
      expect(result?.index, equals(1));
      expect(result?.value, equals(const EqualStub(id: 2, name: 'b')));
    });

    test('works with single element list that matches', () {
      const list = [42];

      final result = list.firstIndexedWhereOrNull((e) => e == 42);

      expect(result, isNotNull);
      expect(result?.index, equals(0));
      expect(result?.value, equals(42));
    });

    test('returns null for single element list that does not match', () {
      const list = [42];

      final result = list.firstIndexedWhereOrNull((e) => e == 99);

      expect(result, isNull);
    });

    test('predicate is only called until first match is found', () {
      var callCount = 0;
      const list = [1, 2, 3, 4, 5];

      final _ = list.firstIndexedWhereOrNull((e) {
        callCount++;
        return e == 3;
      });

      // Should only call for elements 1, 2, and 3
      expect(callCount, equals(3));
    });

    test('works with nullable elements', () {
      const list = [1, null, 3, null, 5];

      final result = list.firstIndexedWhereOrNull((e) => e == null);

      expect(result, isNotNull);
      expect(result?.index, equals(1));
      expect(result?.value, isNull);
    });
  });

  group('lastIndexedWhereOrNull()', () {
    test('returns last element with index that matches predicate', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.lastIndexedWhereOrNull((e) => e < 4);

      expect(result, isNotNull);
      expect(result?.index, equals(2));
      expect(result?.value, equals(3));
    });

    test('returns null when no element matches predicate', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.lastIndexedWhereOrNull((e) => e > 10);

      expect(result, isNull);
    });

    test('returns last match when multiple elements satisfy predicate', () {
      const list = [1, 5, 8, 10, 15];

      final result = list.lastIndexedWhereOrNull((e) => e > 7);

      expect(result, isNotNull);
      expect(result?.index, equals(4));
      expect(result?.value, equals(15));
    });

    test('returns null for empty list', () {
      const list = <int>[];

      final result = list.lastIndexedWhereOrNull((e) => e > 0);

      expect(result, isNull);
    });

    test('returns last element if it matches', () {
      const list = [1, 2, 3, 4, 10];

      final result = list.lastIndexedWhereOrNull((e) => e > 9);

      expect(result, isNotNull);
      expect(result?.index, equals(4));
      expect(result?.value, equals(10));
    });

    test('returns first element if only it matches', () {
      const list = [10, 5, 3, 2];

      final result = list.lastIndexedWhereOrNull((e) => e > 9);

      expect(result, isNotNull);
      expect(result?.index, equals(0));
      expect(result?.value, equals(10));
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      final result = list.lastIndexedWhereOrNull((e) => e.id < 3);

      expect(result, isNotNull);
      expect(result?.index, equals(1));
      expect(result?.value, equals(const EqualStub(id: 2, name: 'b')));
    });

    test('works with single element list that matches', () {
      const list = [42];

      final result = list.lastIndexedWhereOrNull((e) => e == 42);

      expect(result, isNotNull);
      expect(result?.index, equals(0));
      expect(result?.value, equals(42));
    });

    test('returns null for single element list that does not match', () {
      const list = [42];

      final result = list.lastIndexedWhereOrNull((e) => e == 99);

      expect(result, isNull);
    });

    test('returns different result than firstIndexedWhereOrNull for multiple matches', () {
      const list = [5, 10, 15, 20, 25];

      final firstResult = list.firstIndexedWhereOrNull((e) => e >= 10);
      final lastResult = list.lastIndexedWhereOrNull((e) => e >= 10);

      expect(firstResult?.index, equals(1));
      expect(firstResult?.value, equals(10));
      expect(lastResult?.index, equals(4));
      expect(lastResult?.value, equals(25));
    });

    test('works with nullable elements', () {
      const list = [1, null, 3, null, 5];

      final result = list.lastIndexedWhereOrNull((e) => e == null);

      expect(result, isNotNull);
      expect(result?.index, equals(3));
      expect(result?.value, isNull);
    });

    test('returns last occurrence among duplicates', () {
      const list = [1, 2, 2, 2, 3];

      final result = list.lastIndexedWhereOrNull((e) => e == 2);

      expect(result, isNotNull);
      expect(result?.index, equals(3));
      expect(result?.value, equals(2));
    });
  });

  group('difference()', () {
    test('returns no difference when both lists are empty', () {
      const list1 = <EqualStub>[];
      const list2 = <EqualStub>[];

      final result = list1.difference(
        list2,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );
      final result2 = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasDifference, isFalse);
      expect(result.hasAdded, isFalse);
      expect(result.hasRemoved, isFalse);
      expect(result.hasUpdated, isFalse);
      expect(result2.hasDifference, isFalse);
    });

    test('returns no difference when lists are identical', () {
      const list1 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];

      const list2 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];

      final result = list1.difference(
        list2,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      final result2 = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasDifference, isFalse);
      expect(result.added, isEmpty);
      expect(result.removed, isEmpty);
      expect(result.updated, isEmpty);
      expect(result2.hasDifference, isFalse);
    });

    test('works with simple primitives using default equality', () {
      const list1 = [1, 2, 3, 4];
      const list2 = [1, 3, 4, 5];

      final result = list2.difference(list1);

      expect(result.hasDifference, isTrue);
      expect(result.added, equals([5]));
      expect(result.removed, equals([2]));
      expect(result.updated, isEmpty);
    });

    test('detects only additions when current list has new items', () {
      const list1 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];
      const list2 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
        EqualStub(id: 3, name: '3'),
        EqualStub(id: 4, name: '4'),
      ];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasAdded, isTrue);
      expect(result.hasRemoved, isFalse);
      expect(result.hasUpdated, isFalse);
      expect(result.added, hasLength(2));
      expect(result.added, contains(const EqualStub(id: 3, name: '3')));
      expect(result.added, contains(const EqualStub(id: 4, name: '4')));
    });

    test('detects only removals when current list has fewer items', () {
      const list1 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
        EqualStub(id: 3, name: '3'),
      ];
      const list2 = [
        EqualStub(id: 1, name: '1'),
      ];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasRemoved, isTrue);
      expect(result.hasAdded, isFalse);
      expect(result.hasUpdated, isFalse);
      expect(result.removed, hasLength(2));
      expect(result.removed, contains(const EqualStub(id: 2, name: '2')));
      expect(result.removed, contains(const EqualStub(id: 3, name: '3')));
    });

    group('with mixed changes', () {
      late List<EqualStub> list1;
      late List<EqualStub> list2;

      setUp(() {
        list1 = [
          const EqualStub(id: 1, name: '1'),
          const EqualStub(id: 2, name: '2'),
          const EqualStub(id: 4, name: '4'),
        ];
        list2 = [
          const EqualStub(id: 1, name: '1'),
          const EqualStub(id: 3, name: '3'),
          const EqualStub(id: 4, name: '5'),
        ];
      });

      group('calculates difference correctly', () {
        late IterableDifference<EqualStub> result;

        setUp(() {
          result = list2.difference(
            list1,
            equals: (p0, p1) => p0.id == p1.id,
            hashCode: (item) => item.id.hashCode,
          );
        });

        test('reports difference exists', () {
          expect(result.hasDifference, isTrue);
          expect(result.hasAdded, isTrue);
          expect(result.hasRemoved, isTrue);
          expect(result.hasUpdated, isTrue);
        });

        test('detects added items', () {
          expect(result.added, hasLength(1));
          expect(result.added, equals([const EqualStub(id: 3, name: '3')]));
        });

        test('detects removed items', () {
          expect(result.removed, hasLength(1));
          expect(result.removed, equals([const EqualStub(id: 2, name: '2')]));
        });

        test('detects updated items', () {
          expect(result.updated, hasLength(1));
          expect(
            result.updated,
            equals([
              const IterableUpdate(
                old: EqualStub(id: 4, name: '4'),
                updated: EqualStub(id: 4, name: '5'),
              ),
            ]),
          );
        });

        test('preserves actual list reference', () {
          expect(result.actual, same(list2));
        });
      });

      group('with custom includeUpdatedWhen', () {
        late IterableDifference<EqualStub> result;

        setUp(() {
          result = list2.difference(
            list1,
            equals: (p0, p1) => p0.id == p1.id,
            hashCode: (item) => item.id.hashCode,
            includeUpdatedWhen: (item, other) => item.id != other.id,
          );
        });

        test('respects custom update predicate', () {
          expect(result.hasDifference, isTrue);
          expect(result.hasUpdated, isFalse);
          expect(result.updated, isEmpty);
        });

        test('still detects additions and removals', () {
          expect(result.hasAdded, isTrue);
          expect(result.hasRemoved, isTrue);
        });
      });
    });

    test('handles duplicate items in lists', () {
      const list1 = [1, 2, 2, 3];
      const list2 = [1, 1, 3, 4];

      final result = list2.difference(list1);

      expect(result.added, contains(4));
      expect(result.removed, contains(2));
    });

    test('preserves order in LinkedHashSet', () {
      const list1 = [5, 3, 1];
      const list2 = [1, 3, 5, 7];

      final result = list2.difference(list1);

      // Added items should maintain order from current list
      expect(result.added, equals([7]));
      expect(result.removed, isEmpty);
    });

    test('works with custom equals that considers more than one field', () {
      const list1 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 1, name: 'c'), // Same id, different name
      ];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id && p0.name == p1.name,
        hashCode: (item) => Object.hash(item.id, item.name),
      );

      expect(result.hasAdded, isTrue);
      expect(result.hasRemoved, isTrue);
      expect(result.added, contains(const EqualStub(id: 1, name: 'c')));
      expect(result.removed, contains(const EqualStub(id: 2, name: 'b')));
    });

    test('handles large lists efficiently', () {
      final list1 = List.generate(1000, (i) => EqualStub(id: i, name: 'item$i'));
      final list2 = [
        ...List.generate(500, (i) => EqualStub(id: i, name: 'item$i')),
        ...List.generate(500, (i) => EqualStub(id: i + 1000, name: 'item${i + 1000}')),
      ];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.added, hasLength(500));
      expect(result.removed, hasLength(500));
      expect(result.updated, isEmpty);
    });

    test('returns correct difference when current list is empty', () {
      const list1 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];
      const list2 = <EqualStub>[];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasRemoved, isTrue);
      expect(result.hasAdded, isFalse);
      expect(result.hasUpdated, isFalse);
      expect(result.removed, hasLength(2));
      expect(result.actual, isEmpty);
    });

    test('returns correct difference when other list is empty', () {
      const list1 = <EqualStub>[];
      const list2 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];

      final result = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasAdded, isTrue);
      expect(result.hasRemoved, isFalse);
      expect(result.hasUpdated, isFalse);
      expect(result.added, hasLength(2));
    });

    test('includeUpdatedWhen is only called for items that exist in both', () {
      var callCount = 0;
      const list1 = [
        EqualStub(id: 1, name: '1'),
        EqualStub(id: 2, name: '2'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'updated'),
        EqualStub(id: 3, name: '3'),
      ];

      final _ = list2.difference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
        includeUpdatedWhen: (current, previous) {
          callCount++;
          return current.name != previous.name;
        },
      );

      // Should only be called for id:1 which exists in both lists
      expect(callCount, equals(1));
    });
  });

  group('indexedDifference()', () {
    test('returns empty result when both lists are identical', () {
      const list1 = [1, 2, 3, 4];
      const list2 = [1, 2, 3, 4];

      final result = list2.indexedDifference(list1);

      expect(result.hasDifference, isFalse);
      expect(result.hasAdded, isFalse);
      expect(result.hasRemoved, isFalse);
      expect(result.hasUpdated, isFalse);
    });

    test('detects insertions with correct indices', () {
      const list1 = [1, 2, 3, 4];
      const list2 = [1, 5, 3, 6];

      final result = list2.indexedDifference(list1);

      expect(result.hasAdded, isTrue);
      expect(result.added, hasLength(2));
      expect(result.added.any((i) => i.data == 5 && i.index == 1), isTrue);
      expect(result.added.any((i) => i.data == 6 && i.index == 3), isTrue);
    });

    test('detects removals with correct indices', () {
      const list1 = [1, 2, 3, 4];
      const list2 = [1, 5, 3, 6];

      final result = list2.indexedDifference(list1);

      expect(result.hasRemoved, isTrue);
      expect(result.removed, hasLength(2));
      expect(result.removed.any((r) => r.data == 2 && r.index == 1), isTrue);
      expect(result.removed.any((r) => r.data == 4 && r.index == 3), isTrue);
    });

    test('results contain all change types', () {
      const list1 = [1, 2, 3, 4];
      const list2 = [1, 5, 3, 6];

      final result = list2.indexedDifference(list1);

      expect(result.hasDifference, isTrue);
      expect(result.removed, hasLength(2));
      expect(result.added, hasLength(2));
    });

    test('detects updates with old and new indexed values', () {
      const list1 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'updated'),
        EqualStub(id: 3, name: 'c'),
      ];

      final result = list2.indexedDifference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.hasUpdated, isTrue);
      expect(result.updated, hasLength(1));

      final update = result.updated.first;
      expect(update.old.index, equals(1));
      expect(update.old.value, equals(const EqualStub(id: 2, name: 'b')));
      expect(update.updated.index, equals(1));
      expect(update.updated.value, equals(const EqualStub(id: 2, name: 'updated')));
      expect(update.index, equals(1)); // Should return updated.index
    });

    test('handles empty lists', () {
      const list1 = <int>[];
      const list2 = <int>[];

      final result = list2.indexedDifference(list1);

      expect(result.hasDifference, isFalse);
    });

    test('handles adding to empty list', () {
      const list1 = <int>[];
      const list2 = [1, 2, 3];

      final result = list2.indexedDifference(list1);

      expect(result.hasAdded, isTrue);
      expect(result.added, hasLength(3));
      expect(result.hasRemoved, isFalse);
      expect(result.hasUpdated, isFalse);
    });

    test('handles removing all items', () {
      const list1 = [1, 2, 3];
      const list2 = <int>[];

      final result = list2.indexedDifference(list1);

      expect(result.hasRemoved, isTrue);
      expect(result.removed, hasLength(3));
      expect(result.hasAdded, isFalse);
      expect(result.hasUpdated, isFalse);
    });

    test('respects custom includeUpdatedWhen predicate', () {
      const list1 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'updated'),
        EqualStub(id: 2, name: 'b'),
      ];

      final result = list2.indexedDifference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
        includeUpdatedWhen: (item, other) => item.id != other.id,
      );

      // Should not include updates since ids are always equal
      expect(result.hasDifference, isFalse);
    });

    test('works with complex mixed changes', () {
      const list1 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
        EqualStub(id: 4, name: 'd'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 5, name: 'e'),
        EqualStub(id: 3, name: 'updated'),
        EqualStub(id: 6, name: 'f'),
      ];

      final result = list2.indexedDifference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
      );

      expect(result.removed, hasLength(2)); // id:2 and id:4
      expect(result.added, hasLength(2)); // id:5 and id:6
      expect(result.updated, hasLength(1)); // id:3 updated
    });

    test('handles duplicates by using first occurrence', () {
      const list1 = [1, 2, 2, 3];
      const list2 = [1, 2, 2, 4];

      final result = list2.indexedDifference(list1);

      // With duplicates, behavior depends on HashMap handling
      // Should detect that 3 was removed and 4 was added
      expect(result.removed.any((r) => r.data == 3), isTrue);
      expect(result.added.any((i) => i.data == 4), isTrue);
    });

    test('works with single element lists', () {
      const list1 = [1];
      const list2 = [2];

      final result = list2.indexedDifference(list1);

      expect(result.hasDifference, isTrue);
      expect(result.removed, hasLength(1));
      expect(result.added, hasLength(1));
    });

    test('maintains index information correctly', () {
      const list1 = [1, 2, 3];
      const list2 = [4, 5, 6];

      final result = list2.indexedDifference(list1);

      // All elements at their respective indices
      expect(result.removed, hasLength(3));
      expect(result.added, hasLength(3));

      // Check that indices are preserved
      for (var i = 0; i < result.removed.length; i++) {
        expect(result.removed.any((r) => r.index == i), isTrue);
      }
      for (var i = 0; i < result.added.length; i++) {
        expect(result.added.any((ins) => ins.index == i), isTrue);
      }
    });

    test('includeUpdatedWhen only affects updates, not inserts or removes', () {
      const list1 = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
      ];
      const list2 = [
        EqualStub(id: 1, name: 'updated'),
        EqualStub(id: 3, name: 'c'),
      ];

      final result = list2.indexedDifference(
        list1,
        equals: (p0, p1) => p0.id == p1.id,
        hashCode: (item) => item.id.hashCode,
        includeUpdatedWhen: (item, other) => false, // Never include updates
      );

      // Should still have inserts and removes
      expect(result.added, hasLength(1));
      expect(result.removed, hasLength(1));
      expect(result.updated, isEmpty);
    });

    test('default includeUpdatedWhen uses value equality', () {
      const list1 = [1, 2, 3];
      const list2 = [1, 2, 3];

      final result = list2.indexedDifference(list1);

      // With identical values, default equality should not trigger updates
      expect(result.hasDifference, isFalse);
    });

    test('preserves actual list reference', () {
      const list1 = [1, 2, 3];
      const list2 = [4, 5, 6];

      final result = list2.indexedDifference(list1);

      expect(result.actual, same(list2));
    });
  });
}
