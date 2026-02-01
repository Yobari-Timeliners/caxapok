// Example
// ignore_for_file: avoid_print

import 'package:caxapok/src/extension/list_extension.dart';

void main() {
  print('=== NearestAt Advanced Examples ===\n');

  // Basic usage
  print('1. Basic usage:');

  final basicList = [1, 2, null, null, 5];
  print('   List: $basicList');
  print('   nearestAt(3): ${basicList.nearestAt(3)}'); // 5
  print('   nearestAt(2): ${basicList.nearestAt(2)}'); // 2
  print('');

  // Search direction
  print('2. Search direction:');
  final dirList = <int?>[1, 2, null, 4, 5];
  print('   List: $dirList');
  print(
    '   nearestAt(2, left only): ${dirList.nearestAt(
      2,
      configuration: const .new(
        searchDirection: .left,
      ),
    )}',
  ); // 2
  print(
    '   nearestAt(2, right only): ${dirList.nearestAt(
      2,
      configuration: const .new(
        searchDirection: .right,
        bounds: .clamp,
      ),
    )}',
  ); // 4
  print('');

  // Custom predicate
  print('3. Custom predicate (positive numbers only):');
  final predList = [1, 2, -3, -4, 5];
  print('   List: $predList');
  print(
    '   nearestAt(2, positive only): ${predList.nearestAt(
      2,
      configuration: .new(
        searchDirection: .both,
        bounds: .clamp,
        predicate: (e) => e > 0,
      ),
    )}',
  ); // 2
  print('');

  // Max distance
  print('4. Max distance:');
  final distList = <int?>[1, null, null, null, 5];
  print('   List: $distList');
  print(
    '   nearestAt(2, maxDistance=1): ${distList.nearestAt(
      2,
      configuration: const .new(
        searchDirection: .both,
        bounds: .clamp,
        maxDistance: 1,
      ),
    )}',
  ); // null
  print(
    '   nearestAt(2, maxDistance=2): ${distList.nearestAt(
      2,
      configuration: const .new(
        searchDirection: .both,
        bounds: .clamp,
        maxDistance: 2,
      ),
    )}',
  ); // 1
  print('');

  // Fallback value
  print('5. Fallback value:');
  final fallbackList = <int?>[null, null, null];
  print('   List: $fallbackList');
  print(
    '   nearestAt(1, fallback=42): ${fallbackList.nearestAt(
      1,
      configuration: .new(
        searchDirection: .both,
        bounds: .clamp,
        fallback: () => 42,
      ),
    )}',
  ); // 42
  print('');

  // Bounds strategies
  print('6. Bounds strategies:');
  final boundsList = [10, 20, 30];
  print('   List: $boundsList');
  print(
    '   nearestAt(-1, clamp): ${boundsList.nearestAt(
      -1,
      configuration: const .new(
        searchDirection: .both,
        bounds: .clamp,
      ),
    )}',
  ); // 10
  print(
    '   nearestAt(-1, wrap): ${boundsList.nearestAt(
      -1,
      configuration: const .new(
        searchDirection: .both,
        bounds: .wrap,
      ),
    )}',
  ); // 30
  print(
    '   nearestAt(-1, nullify): ${boundsList.nearestAt(
      -1,
      configuration: const .new(
        searchDirection: .both,
        bounds: .nullify,
      ),
    )}',
  ); // null
  print('');

  // Combined configuration
  print('7. Combined configuration:');
  final combinedList = [2, 4, 6, 7, 9, 10];
  print('   List: $combinedList');
  print(
    '   nearestAt(3, even numbers, right only, maxDistance=2): ${combinedList.nearestAt(
      3,
      configuration: .new(
        searchDirection: .right,
        bounds: .clamp,
        maxDistance: 2,
        predicate: (e) => e.isEven,
      ),
    )}',
  ); // 10
  print('');
}
