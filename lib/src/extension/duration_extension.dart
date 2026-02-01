extension DurationExtension on Duration {
  /// Returns the maximum of two [Duration] values.
  ///
  /// Compares [a] and [b] and returns the longer duration.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d1 = Duration(seconds: 5);
  /// final d2 = Duration(seconds: 10);
  /// final result = DurationExtension.max(d1, d2);
  /// print(result); // Duration(seconds: 10)
  /// ```
  static Duration max(Duration a, Duration b) => a > b ? a : b;

  /// Returns the minimum of two [Duration] values.
  ///
  /// Compares [a] and [b] and returns the shorter duration.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d1 = Duration(seconds: 5);
  /// final d2 = Duration(seconds: 10);
  /// final result = DurationExtension.min(d1, d2);
  /// print(result); // Duration(seconds: 5)
  /// ```
  static Duration min(Duration a, Duration b) => a > b ? b : a;

  /// Clamps this duration to be within the range [min] to [max].
  ///
  /// If this duration is less than [min], returns [min].
  /// If this duration is greater than [max], returns [max].
  /// Otherwise, returns this duration unchanged.
  ///
  /// Example:
  ///
  /// ```dart
  /// final duration = Duration(seconds: 15);
  /// final min = Duration(seconds: 10);
  /// final max = Duration(seconds: 20);
  ///
  /// print(duration.clamp(min, max)); // Duration(seconds: 15)
  ///
  /// final tooShort = Duration(seconds: 5);
  /// print(tooShort.clamp(min, max)); // Duration(seconds: 10)
  ///
  /// final tooLong = Duration(seconds: 30);
  /// print(tooLong.clamp(min, max)); // Duration(seconds: 20)
  /// ```
  Duration clamp(Duration min, Duration max) => .new(
    microseconds: inMicroseconds.clamp(min.inMicroseconds, max.inMicroseconds),
  );

  /// Returns `true` if this duration is equal to [Duration.zero].
  ///
  /// Example:
  ///
  /// ```dart
  /// final zero = Duration.zero;
  /// print(zero.isZero); // true
  ///
  /// final notZero = Duration(seconds: 1);
  /// print(notZero.isZero); // false
  /// ```
  bool get isZero => this == Duration.zero;

  /// Returns `true` if this duration is not equal to [Duration.zero].
  ///
  /// Example:
  ///
  /// ```dart
  /// final zero = Duration.zero;
  /// print(zero.isNotZero); // false
  ///
  /// final notZero = Duration(seconds: 1);
  /// print(notZero.isNotZero); // true
  /// ```
  bool get isNotZero => !isZero;

  /// Divides this duration by a [divider] and returns the result.
  ///
  /// Performs integer division on the microseconds value.
  ///
  /// Example:
  ///
  /// ```dart
  /// final duration = Duration(seconds: 10);
  /// final half = duration / 2;
  /// print(half); // Duration(seconds: 5)
  ///
  /// final third = duration / 3;
  /// print(third); // Duration(seconds: 3, milliseconds: 333)
  /// ```
  Duration operator /(double divider) => .new(microseconds: inMicroseconds ~/ divider);
}
