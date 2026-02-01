// Example
// ignore_for_file: avoid_print

import 'package:caxapok/caxapok.dart';

void main() {
  // kotlin let extension
  final mathResult = 12.let((it) => it * 2).let((it) => it + 3);
  print(mathResult); // prints 27

  // kotlin also extension
  final numbers = ['one', 'two', 'three'];
  // prints "The list elements before adding new one: [one, two, three]"
  numbers.also((it) => print('The list elements before adding new one: $it')).add('four');
}
