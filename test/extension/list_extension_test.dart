import 'package:caxapok/src/extension/list_extension.dart';
import 'package:test/test.dart';

import '../stubs.dart';

void main() {
  group('tryGet()', () {
    test('returns element at valid index', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.tryGet(2), equals(3));
      expect(list.tryGet(0), equals(1));
      expect(list.tryGet(4), equals(5));
    });

    test('returns null for negative index', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.tryGet(-1), isNull);
      expect(list.tryGet(-5), isNull);
      expect(list.tryGet(-100), isNull);
    });

    test('returns null for index beyond list length', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.tryGet(5), isNull);
      expect(list.tryGet(10), isNull);
      expect(list.tryGet(100), isNull);
    });

    test('returns null for empty list', () {
      const list = <int>[];

      expect(list.tryGet(0), isNull);
      expect(list.tryGet(1), isNull);
      expect(list.tryGet(-1), isNull);
    });

    test('returns first element at index 0', () {
      const list = [10, 20, 30];

      expect(list.tryGet(0), equals(10));
    });

    test('returns last element at index length-1', () {
      const list = [10, 20, 30];

      expect(list.tryGet(2), equals(30));
    });

    test('returns null at boundary index equal to length', () {
      const list = [1, 2, 3];

      expect(list.tryGet(3), isNull);
    });

    test('works with single element list', () {
      const list = [42];

      expect(list.tryGet(0), equals(42));
      expect(list.tryGet(1), isNull);
      expect(list.tryGet(-1), isNull);
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      expect(list.tryGet(1), equals(const EqualStub(id: 2, name: 'b')));
      expect(list.tryGet(5), isNull);
    });

    test('works with nullable elements', () {
      const list = [1, null, 3];

      expect(list.tryGet(0), equals(1));
      expect(list.tryGet(1), isNull);
      expect(list.tryGet(2), equals(3));
    });

    test('distinguishes between null element and out of bounds', () {
      const list = [1, null, 3];

      // Null element at valid index
      final resultValid = list.tryGet(1);
      expect(resultValid, isNull);

      // Out of bounds also returns null
      final resultOutOfBounds = list.tryGet(10);
      expect(resultOutOfBounds, isNull);

      // Both are null, but for different reasons - this is expected behavior
    });

    test('works with strings', () {
      const list = ['a', 'b', 'c'];

      expect(list.tryGet(0), equals('a'));
      expect(list.tryGet(2), equals('c'));
      expect(list.tryGet(3), isNull);
    });

    test('works with large indices', () {
      const list = [1, 2, 3];

      expect(list.tryGet(1000000), isNull);
    });

    test('works with very negative indices', () {
      const list = [1, 2, 3];

      expect(list.tryGet(-1000000), isNull);
    });
  });

  group('nextAfter()', () {
    test('returns next element in sequence', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.nextAfter(2), equals(3));
      expect(list.nextAfter(3), equals(4));
    });

    test('wraps around from last element to first', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.nextAfter(5), equals(1));
    });

    test('returns second element when item is first', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.nextAfter(1), equals(2));
    });

    test('works with single element list', () {
      const list = [42];

      expect(list.nextAfter(42), equals(42));
    });

    test('works with two element list', () {
      const list = [1, 2];

      expect(list.nextAfter(1), equals(2));
      expect(list.nextAfter(2), equals(1));
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      expect(
        list.nextAfter(const EqualStub(id: 2, name: 'b')),
        equals(const EqualStub(id: 3, name: 'c')),
      );
      expect(
        list.nextAfter(const EqualStub(id: 3, name: 'c')),
        equals(const EqualStub(id: 1, name: 'a')),
      );
    });

    test('handles duplicates by finding first occurrence', () {
      const list = [1, 2, 2, 3, 4];

      // Should find first occurrence of 2 at index 1, next is 2 at index 2
      expect(list.nextAfter(2), equals(2));
    });

    test('returns first element when item not found in list', () {
      const list = [1, 2, 3, 4, 5];

      // indexOf returns -1, so (−1 + 1) % 5 = 0
      expect(list.nextAfter(99), equals(1));
    });

    test('works with strings', () {
      const list = ['a', 'b', 'c', 'd'];

      expect(list.nextAfter('b'), equals('c'));
      expect(list.nextAfter('d'), equals('a'));
    });

    test('maintains circular iteration', () {
      const list = [1, 2, 3];

      var current = 1;
      current = list.nextAfter(current); // 2
      expect(current, equals(2));

      current = list.nextAfter(current); // 3
      expect(current, equals(3));

      current = list.nextAfter(current); // 1 (wrapped)
      expect(current, equals(1));

      current = list.nextAfter(current); // 2
      expect(current, equals(2));
    });

    test('works with nullable elements', () {
      const list = [1, null, 3, 4];

      expect(list.nextAfter(1), isNull);
      expect(list.nextAfter(null), equals(3));
      expect(list.nextAfter(4), equals(1));
    });

    test('works with negative numbers', () {
      const list = [-2, -1, 0, 1, 2];

      expect(list.nextAfter(-1), equals(0));
      expect(list.nextAfter(2), equals(-2));
    });
  });

  group('maybeNextAfter()', () {
    test('returns next element in sequence', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.maybeNextAfter(2), equals(3));
      expect(list.maybeNextAfter(3), equals(4));
    });

    test('returns null when item is last element', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.maybeNextAfter(5), isNull);
    });

    test('returns second element when item is first', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.maybeNextAfter(1), equals(2));
    });

    test('returns null for single element list', () {
      const list = [42];

      expect(list.maybeNextAfter(42), isNull);
    });

    test('works with two element list', () {
      const list = [1, 2];

      expect(list.maybeNextAfter(1), equals(2));
      expect(list.maybeNextAfter(2), isNull);
    });

    test('returns null for empty list', () {
      const list = <int>[];

      expect(list.maybeNextAfter(1), isNull);
    });

    test('returns null when item not found', () {
      const list = [1, 2, 3, 4, 5];

      expect(list.maybeNextAfter(99), isNull);
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      expect(
        list.maybeNextAfter(const EqualStub(id: 2, name: 'b')),
        equals(const EqualStub(id: 3, name: 'c')),
      );
      expect(
        list.maybeNextAfter(const EqualStub(id: 3, name: 'c')),
        isNull,
      );
    });

    test('handles duplicates by finding first occurrence', () {
      const list = [1, 2, 2, 3, 4];

      // Should find first occurrence of 2 at index 1, next is 2 at index 2
      expect(list.maybeNextAfter(2), equals(2));
    });

    test('works with strings', () {
      const list = ['a', 'b', 'c', 'd'];

      expect(list.maybeNextAfter('b'), equals('c'));
      expect(list.maybeNextAfter('d'), isNull);
    });

    test('stops at end without wrapping', () {
      const list = [1, 2, 3];

      const current = 1;
      final next1 = list.maybeNextAfter(current);
      expect(next1, equals(2));

      if (next1 != null) {
        final next2 = list.maybeNextAfter(next1);
        expect(next2, equals(3));

        if (next2 != null) {
          final next3 = list.maybeNextAfter(next2);
          expect(next3, isNull); // Stops here, no wrap
        }
      }
    });

    test('works with nullable elements', () {
      const list = [1, null, 3, 4];

      expect(list.maybeNextAfter(1), isNull);
      expect(list.maybeNextAfter(null), equals(3));
      expect(list.maybeNextAfter(3), equals(4));
      expect(list.maybeNextAfter(4), isNull);
    });

    test('works with negative numbers', () {
      const list = [-2, -1, 0, 1, 2];

      expect(list.maybeNextAfter(-1), equals(0));
      expect(list.maybeNextAfter(2), isNull);
    });

    test('difference from nextAfter on last element', () {
      const list = [1, 2, 3];

      // nextAfter wraps around
      expect(list.nextAfter(3), equals(1));

      // maybeNextAfter returns null
      expect(list.maybeNextAfter(3), isNull);
    });
  });

  group('resizedDiscrete()', () {
    test('returns original list when empty', () {
      const list = <int>[];

      final result = list.resizedDiscrete(5);

      expect(result, same(list));
    });

    test('returns original list when length is the same', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.resizedDiscrete(5);

      expect(result, same(list));
    });

    test('downsamples to smaller length', () {
      const list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      final result = list.resizedDiscrete(5);

      expect(result, hasLength(5));
      // Should sample elements proportionally across the list
      expect(result, isNotEmpty);
    });

    test('upsamples to larger length', () {
      const list = [1, 2, 3];

      final result = list.resizedDiscrete(5);

      expect(result, hasLength(5));
      // Should duplicate some elements to reach target length
      expect(result, isNotEmpty);
    });

    test('downsamples to single element', () {
      const list = [1, 2, 3, 4, 5];

      final result = list.resizedDiscrete(1);

      expect(result, hasLength(1));
      // Should pick one element from the list
      expect(result.first, isIn(list));
    });

    test('upsamples single element to multiple', () {
      const list = [42];

      final result = list.resizedDiscrete(5);

      expect(result, hasLength(5));
      // All elements should be the same
      expect(result, everyElement(equals(42)));
    });

    test('maintains element types', () {
      const list = ['a', 'b', 'c', 'd', 'e'];

      final result = list.resizedDiscrete(3);

      expect(result, hasLength(3));
      expect(result, everyElement(isA<String>()));
    });

    test('works with complex objects', () {
      const list = [
        EqualStub(id: 1, name: 'a'),
        EqualStub(id: 2, name: 'b'),
        EqualStub(id: 3, name: 'c'),
      ];

      final result = list.resizedDiscrete(2);

      expect(result, hasLength(2));
      expect(result, everyElement(isA<EqualStub>()));
    });

    test('handles large downsampling', () {
      final list = List.generate(1000, (i) => i);

      final result = list.resizedDiscrete(10);

      expect(result, hasLength(10));
      // Elements should be spread across the original range
      expect(result.first, lessThan(100));
      expect(result.last, greaterThanOrEqualTo(850));
    });

    test('handles large upsampling', () {
      const list = [1, 2, 3];

      final result = list.resizedDiscrete(100);

      expect(result, hasLength(100));
      // All elements should come from the original list
      for (var item in result) {
        expect(item, isIn(list));
      }
    });

    test('preserves elements from original list', () {
      const list = [10, 20, 30, 40, 50];

      final result = list.resizedDiscrete(3);

      expect(result, hasLength(3));
      // All result elements should exist in original list
      for (var item in result) {
        expect(item, isIn(list));
      }
    });

    test('works with nullable elements', () {
      const list = [1, null, 3, null, 5];

      final result = list.resizedDiscrete(3);

      expect(result, hasLength(3));
      // Should handle nulls correctly
    });

    test('proportional sampling for downsampling', () {
      const list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

      final result = list.resizedDiscrete(5);

      expect(result, hasLength(5));
      // Should sample across the range, not just first or last elements
      expect(result.first, equals(0));
      expect(result.last, greaterThanOrEqualTo(7));
    });

    test('handles two-element list resized to three', () {
      const list = [1, 2];

      final result = list.resizedDiscrete(3);

      expect(result, hasLength(3));
      // Should only contain elements from original list
      for (var item in result) {
        expect(item, isIn([1, 2]));
      }
    });

    test('handles two-element list resized to one', () {
      const list = [1, 2];

      final result = list.resizedDiscrete(1);

      expect(result, hasLength(1));
      expect(result.first, isIn([1, 2]));
    });
  });
}
