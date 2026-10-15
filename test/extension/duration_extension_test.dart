import 'package:caxapok/caxapok.dart';
import 'package:test/test.dart';

void main() {
  const short = Duration(seconds: 5);
  const long = Duration(seconds: 10);

  group('max() / min()', () {
    test('return the longer and shorter duration', () {
      expect(DurationExtension.max(short, long), equals(long));
      expect(DurationExtension.max(long, short), equals(long));
      expect(DurationExtension.min(short, long), equals(short));
      expect(DurationExtension.min(long, short), equals(short));
    });
  });

  group('clamp()', () {
    test('keeps a duration inside the range', () {
      expect(const Duration(seconds: 7).clamp(short, long), equals(const Duration(seconds: 7)));
    });

    test('clamps to the bounds', () {
      expect(Duration.zero.clamp(short, long), equals(short));
      expect(const Duration(minutes: 1).clamp(short, long), equals(long));
    });

    test('throws when min is greater than max', () {
      expect(() => Duration.zero.clamp(long, short), throwsArgumentError);
    });
  });

  group('isZero / isNotZero', () {
    test('detect zero duration', () {
      expect(Duration.zero.isZero, isTrue);
      expect(Duration.zero.isNotZero, isFalse);
      expect(short.isZero, isFalse);
      expect(short.isNotZero, isTrue);
    });
  });

  group('operator /', () {
    test('divides and truncates microseconds', () {
      expect(long / 2, equals(short));
      expect(long / 3, equals(const Duration(microseconds: 3333333)));
      expect(long / 0.5, equals(const Duration(seconds: 20)));
    });
  });
}
