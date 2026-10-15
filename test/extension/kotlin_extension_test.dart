import 'package:caxapok/caxapok.dart';
import 'package:test/test.dart';

void main() {
  group('let()', () {
    test('returns the block result', () {
      expect(12.let((it) => it * 2).let((it) => it + 3), equals(27));
    });

    test('works on null', () {
      const int? value = null;

      expect(value.let((it) => it == null), isTrue);
    });
  });

  group('also()', () {
    test('runs the block and returns the same instance', () {
      final list = [1, 2];
      List<int>? seen;

      final result = list.also((it) => seen = it);

      expect(result, same(list));
      expect(seen, same(list));
    });
  });
}
