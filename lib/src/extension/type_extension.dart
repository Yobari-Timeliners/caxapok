extension TypeExtension<T> on T {
  /// Creates a list of [count] elements, all of which are this value.
  ///
  /// Example:
  ///
  /// ```dart
  /// final value = 42;
  /// final repeatedList = value.repeat(3);
  /// print(repeatedList); // Output: [42, 42, 42]
  /// ```
  List<T> repeat(int count) {
    if (count < 0) {
      return const [];
    }

    return List<T>.filled(count, this);
  }
}
