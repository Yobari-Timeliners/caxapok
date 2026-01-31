import 'package:meta/meta.dart';

extension ListExtension<T> on List<T> {
  /// Get the value [T] at [index].
  ///
  /// If the index is out of bounds, returns `null`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// print(list.tryGet(2)); // 3
  /// print(list.tryGet(10)); // null
  /// print(list.tryGet(-1)); // null
  /// ```
  T? tryGet(int index) {
    if (isEmpty) return null;

    return index >= 0 && index < length ? this[index] : null;
  }

  /// Returns the next value in order after [item].
  ///
  /// If [item] is the last element, returns the first element of the list.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// print(list.nextAfter(2)); // 3
  /// print(list.nextAfter(5)); // 1 (wraps around)
  /// ```
  T nextAfter(T item) {
    final index = indexOf(item);

    final nextIndex = (index + 1) % length;

    return this[nextIndex];
  }

  /// Returns the next value in order after [item], or `null` if [item] is the last element.
  ///
  /// Unlike [nextAfter], this method does not wrap around to the first element.
  ///
  /// Returns `null` if:
  /// * [item] is the last element in the iterable
  /// * [item] is not found in the iterable
  /// * The iterable is empty
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  /// print(list.maybeNextAfter(2)); // 3
  /// print(list.maybeNextAfter(5)); // null (no wrap around)
  /// print(list.maybeNextAfter(99)); // null (not found)
  /// ```
  T? maybeNextAfter(T item) {
    if (isEmpty) return null;

    final index = indexOf(item);

    if (index == -1 || index == length - 1) return null;

    return this[index + 1];
  }

  /// Get the nearest valid element at [index].
  ///
  /// Searches for the nearest element that satisfies the validation criteria.
  /// By default, searches in both directions and only considers non-null elements.
  ///
  /// Use [configuration] to customize search direction, bounds handling,
  /// max distance, validation predicate, and fallback values.
  /// See [NearestAtConfiguration] for all available options.
  ///
  /// Returns `null` if no valid element is found (or the fallback value if specified).
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, null, null, 5];
  /// print(list.nearestAt(3)); // 5
  /// print(list.nearestAt(2)); // 2
  /// ```
  T? nearestAt(
    int index, {
    NearestAtConfiguration<T> configuration = const .new(),
  }) {
    var effectiveIndex = index;

    if (isEmpty) {
      return configuration.fallback?.call();
    }

    final isOutOfBounds = effectiveIndex < 0 || effectiveIndex >= length;

    if (isOutOfBounds) {
      switch (configuration.bounds) {
        case .clamp:
          effectiveIndex = effectiveIndex.clamp(0, length - 1);

        case .wrap:
          effectiveIndex = effectiveIndex % length;
          if (effectiveIndex < 0) effectiveIndex += length;

        case .nullify:
          return configuration.fallback?.call();

        case .error:
          throw RangeError.index(effectiveIndex, this, 'index');
      }
    }

    final isValid = configuration.predicate ?? (T element) => element != null;

    // Check target index based on strategy
    if (configuration.targetIndex == .include) {
      final target = this[effectiveIndex];
      if (isValid(target)) {
        return target;
      }
    }

    // Define search bounds based on direction
    final searchLeft =
        configuration.searchDirection == .left || configuration.searchDirection == .both;
    final searchRight =
        configuration.searchDirection == .right || configuration.searchDirection == .both;

    var leftIndex = effectiveIndex - 1;
    var rightIndex = effectiveIndex + 1;
    var distance = 1;
    final maxDistance = configuration.maxDistance;

    while ((searchLeft && leftIndex >= 0) || (searchRight && rightIndex < length)) {
      if (maxDistance != null && distance > maxDistance) {
        break;
      }

      if (searchLeft && leftIndex >= 0) {
        final left = this[leftIndex];
        if (isValid(left)) {
          return left;
        }
      }

      if (searchRight && rightIndex < length) {
        final right = this[rightIndex];
        if (isValid(right)) {
          return right;
        }
      }

      leftIndex--;
      rightIndex++;
      distance++;
    }

    return configuration.fallback?.call();
  }

  /// Resizes the list to [length] by sampling elements at discrete intervals.
  ///
  /// This method creates a new list by selecting existing elements from the
  /// original list based on calculated indices. It does not interpolate values;
  /// it picks actual elements from the source list.
  ///
  /// If the list is empty or already has the requested [length], returns
  /// the original list unchanged.
  ///
  /// The sampling uses a proportional distribution to maintain representation
  /// across the entire original list.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  /// print(list.resizedDiscrete(5)); // [1, 3, 5, 7, 9]
  /// print(list.resizedDiscrete(3)); // [1, 5, 10]
  ///
  /// final smallList = [1, 2, 3];
  /// print(smallList.resizedDiscrete(5)); // [1, 1, 2, 2, 3]
  /// ```
  List<T> resizedDiscrete(int length) {
    if (isEmpty || this.length == length) return this;

    final factor = this.length / length;
    final newList = <T>[];

    for (var i = 0; i < length; i++) {
      final index = (i * factor).round();
      final discreteItem = this[index.clamp(0, this.length - 1)];
      newList.add(discreteItem);
    }

    return newList;
  }

  /// Removes [count] elements starting at [start] and optionally inserts new elements.
  ///
  /// This method modifies the list in place and returns the removed elements.
  /// Similar to JavaScript's Array.splice() method.
  ///
  /// The [start] parameter specifies the index at which to start removing elements.
  /// The [count] parameter specifies how many elements to remove.
  /// The optional [insert] parameter contains elements to insert at the [start] position.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, 3, 4, 5];
  ///
  /// // Remove 2 elements starting at index 1
  /// final removed = list.splice(start: 1, count: 2);
  /// print(removed); // [2, 3]
  /// print(list); // [1, 4, 5]
  ///
  /// // Remove and insert
  /// final list2 = ['a', 'b', 'c', 'd'];
  /// final removed2 = list2.splice(start: 1, count: 2, insert: ['x', 'y', 'z']);
  /// print(removed2); // ['b', 'c']
  /// print(list2); // ['a', 'x', 'y', 'z', 'd']
  ///
  /// // Insert without removing
  /// final list3 = [1, 2, 5];
  /// list3.splice(start: 2, count: 0, insert: [3, 4]);
  /// print(list3); // [1, 2, 3, 4, 5]
  /// ```
  List<T> splice({
    required int start,
    required int count,
    Iterable<T>? insert,
  }) {
    final result = [...getRange(start, start + count)];
    replaceRange(start, start + count, insert ?? []);

    return result;
  }
}

/// Configuration for customizing the behavior of [ListExtension.nearestAt].
///
/// Allows control over:
/// * [searchDirection] - which direction(s) to search
/// * [bounds] - how to handle out-of-bounds indices
/// * [targetIndex] - how to handle the target index itself
/// * [maxDistance] - limit search distance from target index
/// * [predicate] - custom validation logic
/// * [fallback] - value to return when no valid element is found
@immutable
class NearestAtConfiguration<T> {
  /// The direction to search for valid elements.
  ///
  /// See [NearestAtSearchDirection] for available options.
  final NearestAtSearchDirection searchDirection;

  /// The strategy for handling out-of-bounds indices.
  ///
  /// See [NearestAtBoundsStrategy] for available options.
  final NearestAtBoundsStrategy bounds;

  /// The strategy for handling the target index itself.
  ///
  /// See [NearestAtTargetIndexStrategy] for available options.
  /// Defaults to [NearestAtTargetIndexStrategy.exclude].
  final NearestAtTargetIndexStrategy targetIndex;

  /// The maximum distance to search from the target index.
  ///
  /// If specified, the search stops after checking elements at this distance.
  /// A value of `0` checks only the target index. If `null`, no distance limit.
  final int? maxDistance;

  /// A custom predicate to determine if an element is valid.
  ///
  /// If `null`, elements are valid if non-null. If provided, the first element
  /// where `predicate(element)` returns `true` is returned.
  final bool Function(T element)? predicate;

  /// A fallback function that provides a value when no valid element is found.
  ///
  /// Called when the list is empty, no valid element exists within constraints,
  /// or out-of-bounds with [NearestAtBoundsStrategy.nullify].
  /// If `null`, returns `null` when no valid element is found.
  final T Function()? fallback;

  /// Creates a configuration for [ListExtension.nearestAt].
  const NearestAtConfiguration({
    this.searchDirection = .both,
    this.bounds = .clamp,
    this.targetIndex = .exclude,
    this.maxDistance,
    this.predicate,
    this.fallback,
  });
}

/// Defines the direction to search when looking for the nearest valid element.
///
/// Used in [NearestAtConfiguration] to control which direction(s) the
/// [ListExtension.nearestAt] method searches.
///
/// Example:
///
/// ```dart
/// final list = <int?>[1, 2, null, 4, 5];
///
/// // Search only to the left
/// list.nearestAt(2, configuration: NearestAtConfiguration(
///   searchDirection: NearestAtSearchDirection.left,
///   bounds: NearestAtBoundsStrategy.clamp,
/// )); // 2
///
/// // Search only to the right
/// list.nearestAt(2, configuration: NearestAtConfiguration(
///   searchDirection: NearestAtSearchDirection.right,
///   bounds: NearestAtBoundsStrategy.clamp,
/// )); // 4
/// ```
enum NearestAtSearchDirection {
  /// Search only to the left of the target index.
  ///
  /// The search will start at `index - 1` and continue towards index 0.
  /// If no valid element is found to the left, returns `null` or the fallback value.
  left,

  /// Search only to the right of the target index.
  ///
  /// The search will start at `index + 1` and continue towards the end of the list.
  /// If no valid element is found to the right, returns `null` or the fallback value.
  right,

  /// Search in both directions from the target index (default).
  ///
  /// The search alternates between left and right, checking elements at
  /// increasing distances from the target. When two elements are equidistant,
  /// the left element is preferred.
  both,
}

/// Defines how to handle out-of-bounds indices in [ListExtension.nearestAt].
///
/// Used in [NearestAtConfiguration] to control the behavior when the
/// requested index is negative or beyond the list length.
///
/// Example:
///
/// ```dart
/// final list = [10, 20, 30];
///
/// // Clamp to valid range
/// list.nearestAt(-1, configuration: NearestAtConfiguration(
///   searchDirection: NearestAtSearchDirection.both,
///   bounds: NearestAtBoundsStrategy.clamp,
/// )); // 10 (clamped to index 0)
///
/// // Wrap around
/// list.nearestAt(-1, configuration: NearestAtConfiguration(
///   searchDirection: NearestAtSearchDirection.both,
///   bounds: NearestAtBoundsStrategy.wrap,
/// )); // 30 (wrapped to last index)
///
/// // Return null
/// list.nearestAt(-1, configuration: NearestAtConfiguration(
///   searchDirection: NearestAtSearchDirection.both,
///   bounds: NearestAtBoundsStrategy.nullify,
/// )); // null
/// ```
enum NearestAtBoundsStrategy {
  /// Clamp the index to the valid range [0, length-1].
  ///
  /// Negative indices are clamped to 0, and indices >= length are clamped
  /// to length-1. The search then proceeds from the clamped index.
  clamp,

  /// Wrap the index around using modulo arithmetic.
  ///
  /// This allows negative indices to wrap to the end of the list, and
  /// indices beyond the length to wrap to the beginning.
  ///
  /// Example:
  /// * Index -1 in a list of length 5 becomes index 4
  /// * Index 5 in a list of length 5 becomes index 0
  wrap,

  /// Return null (or the fallback value) for out-of-bounds indices.
  ///
  /// The search is not performed when the index is out of bounds.
  nullify,

  /// Throw a [RangeError] for out-of-bounds indices.
  ///
  /// This provides strict bounds checking and will immediately throw
  /// an error if the index is negative or >= length.
  error,
}

/// Defines how to handle the target index in [ListExtension.nearestAt].
///
/// Used in [NearestAtConfiguration] to control whether the element at the
/// target index should be considered in the search.
///
/// Example:
///
/// ```dart
/// final list = [1, 2, 3, 4, 5];
///
/// // Exclude target index (default)
/// list.nearestAt(1); // 1 (nearest element, excluding index 1)
///
/// // Include target index
/// list.nearestAt(
///   1,
///   configuration: NearestAtConfiguration(
///     searchDirection: NearestAtSearchDirection.both,
///     bounds: NearestAtBoundsStrategy.clamp,
///     targetIndex: NearestAtTargetIndexStrategy.include,
///   ),
/// ); // 2 (element at index 1)
/// ```
enum NearestAtTargetIndexStrategy {
  /// Include the target index in the search.
  ///
  /// The element at the target index is checked first. If it's valid,
  /// it's returned immediately without searching neighbors.
  include,

  /// Exclude the target index from the search (default).
  ///
  /// The search skips the target index and only searches neighboring
  /// elements. This is useful when you want to find the nearest element
  /// that is different from the one at the target index.
  exclude,
}
