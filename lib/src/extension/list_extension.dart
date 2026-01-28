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

  /// Get the nearest element at [index].
  ///
  /// If the index is out of bounds or the list is empty, returns `null`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final list = [1, 2, null, null, 5];
  /// final nearestAt3 = list.nearestAt(3); // 5
  /// final nearestAt2 = list.nearestAt(2); // 2
  /// ```
  T? nearestAt(int index) {
    if (isEmpty || index < 0) return null;

    if (index >= length) return last;

    final target = tryGet(index);
    if (target != null) return target;

    var leftIndex = index - 1;
    var rightIndex = index + 1;

    while (leftIndex >= 0 || rightIndex < length) {
      if (leftIndex >= 0 && tryGet(leftIndex) != null) {
        return tryGet(leftIndex);
      }
      if (rightIndex < length && tryGet(rightIndex) != null) {
        return tryGet(rightIndex);
      }
      leftIndex--;
      rightIndex++;
    }

    return null;
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
