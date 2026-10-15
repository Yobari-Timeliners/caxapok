extension TypeExtension<T> on T {
  /// Creates a list of [count] elements, all of which are this value.
  ///
  /// Returns an empty list if [count] is negative. All elements share the same
  /// instance, so mutating one mutates all.
  ///
  /// Example:
  ///
  /// ```dart
  /// final value = 42;
  /// final repeatedList = value.repeat(3);
  /// print(repeatedList); // Output: [42, 42, 42]
  /// ```
  List<T> repeat(int count) {
    return List<T>.filled(count < 0 ? 0 : count, this);
  }
}
