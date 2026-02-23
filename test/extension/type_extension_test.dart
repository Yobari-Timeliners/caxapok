import 'package:caxapok/src/extension/type_extension.dart';
import 'package:test/test.dart';

import '../stubs.dart';

void main() {
  group('repeat()', () {
    test('returns list with repeated values for positive count', () {
      const value = 42;

      final result = value.repeat(3);

      expect(result, equals([42, 42, 42]));
    });

    test('returns empty list for zero count', () {
      const value = 'hello';

      final result = value.repeat(0);

      expect(result, isEmpty);
    });

    test('returns empty list for negative count', () {
      const value = 7;

      final result = value.repeat(-5);

      expect(result, isEmpty);
    });

    test('works with complex objects', () {
      const value = EqualStub(id: 1, name: 'a');

      final result = value.repeat(2);

      expect(
        result,
        equals(const [
          EqualStub(id: 1, name: 'a'),
          EqualStub(id: 1, name: 'a'),
        ]),
      );
    });

    test('works with nullable values', () {
      const String? value = null;

      final result = value.repeat(2);

      expect(result, equals([null, null]));
    });
  });
}
