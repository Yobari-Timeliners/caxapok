// Example
// ignore_for_file: avoid_print

import 'package:caxapok/caxapok.dart';

Future<void> main() async {
  // List
  print([1, 2, 3].tryGet(10)); // null
  print([1, 2, 3].nextAfter(3)); // 1
  print([1, 2, null, null, 5].nearestAt(3)); // 5
  print([1, 2, 3, 4, 5].splice(start: 1, count: 2)); // [2, 3]

  // Iterable
  final diff = [1, 3, 4].difference([1, 2, 4]);
  print('added: ${diff.added}, removed: ${diff.removed}'); // added: [3], removed: [2]

  // Duration
  print(
    const Duration(seconds: 30).clamp(Duration.zero, const Duration(seconds: 10)),
  ); // 0:00:10.000000

  // Future
  final task = Future.delayed(const Duration(seconds: 5), () => 'done').cancellable(
    onCancel: () => print('cleanup'),
  );
  await task.cancel(); // prints "cleanup"
  try {
    await task;
  } on TaskCancelledException {
    print('cancelled');
  }

  // Kotlin scope functions
  print(12.let((it) => it * 2).let((it) => it + 3)); // 27
  final numbers = ['one', 'two', 'three'];
  // prints "The list elements before adding new one: [one, two, three]"
  numbers.also((it) => print('The list elements before adding new one: $it')).add('four');

  // Any value
  print('a'.repeat(3)); // [a, a, a]
}
