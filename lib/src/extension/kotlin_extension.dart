/// Kotlin scope function extensions.
///
/// [https://kotlinlang.org/docs/scope-functions.html].
extension KotlinExtension<T extends Object?> on T {
  /// Calls the specified function [block] with [T] value as its argument and returns its result.
  ///
  /// [let] can be used to invoke one or more functions on results of call chains.
  /// For example, the following code prints the results of two operations on a collection:
  ///
  /// ```dart
  /// final numbers = ["one", "two", "three", "four", "five"];
  /// final resultList = numbers.map((it) => it.length).where((it) => it > 3);
  /// print(resultList);
  /// ```
  ///
  /// With [let], you can rewrite the above example so that you're not assigning the result of
  /// the list operations to a variable:
  ///
  /// ```dart
  /// final numbers = ["one", "two", "three", "four", "five"];
  /// numbers.map((it) => it.length).where((it) => it > 3).let((it) {
  ///     print(it);
  ///     // and more function calls if needed
  /// });
  /// ```
  R let<R>(R Function(T value) block) {
    return block(this);
  }

  /// Calls the specified function [block] with [T] value as its argument and returns [T] value.
  ///
  /// [also] is useful for performing some actions that take the context object as an argument.
  /// Use also for actions that need a reference to the object rather than its properties and functions,
  /// or when you don't want to shadow the this reference from an outer scope.
  ///
  /// When you see [also] in code, you can read it as " and also do the following with the object."
  ///
  /// ```dart
  /// final numbers = ["one", "two", "three"];
  /// numbers
  ///     .also((it) => print("The list elements before adding new one: $it"))
  ///     .add("four");
  /// ```
  T also(void Function(T value) block) {
    block(this);
    return this;
  }
}
