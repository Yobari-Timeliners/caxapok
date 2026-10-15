<p align="center">
  <img src="https://raw.githubusercontent.com/Yobari-Timeliners/caxapok/main/doc/banner.png" alt="caxapok: a sugar cube on a retro refined-sugar pack" width="440">
</p>

<p align="center">
  <a href="https://github.com/Yobari-Timeliners/caxapok/actions/workflows/ci.yml"><img src="https://github.com/Yobari-Timeliners/caxapok/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://raw.githubusercontent.com/Yobari-Timeliners/caxapok/main/doc/badge.png" alt="caxap ok" width="83">
</p>

<p align="center"><b>Syntactic sugar for Dart:</b> small, tested extensions for everyday code.</p>

## Install

```sh
dart pub add caxapok
```

```dart
import 'package:caxapok/caxapok.dart';
```

## Features

| Extension | Members |
| --- | --- |
| `List` | `tryGet`, `nextAfter`, `maybeNextAfter`, `nearestAt`, `resizedDiscrete`, `splice` |
| `Iterable` | `separated`, `firstIndexedWhereOrNull`, `lastIndexedWhereOrNull`, `difference`, `indexedDifference` |
| `Duration` | `DurationExtension.max`, `DurationExtension.min`, `clamp`, `isZero`, `isNotZero`, `/` |
| `Future` | `cancellable` → `CancellableTask`, `minDuration` |
| `Future<T> Function()` | `retry` |
| Any value | `let`, `also` (Kotlin scope functions), `repeat` |

## Usage

```dart
// List
[1, 2, 3].tryGet(10); // null
[1, 2, 3].nextAfter(3); // 1
[1, 2, null, null, 5].nearestAt(3); // 5
[1, 2, 3, 4, 5].splice(start: 1, count: 2); // [2, 3]

// Iterable
[1, 2, 3].separated(0); // (1, 0, 2, 0, 3)
final diff = [1, 3, 4].difference([1, 2, 4]);
diff.added; // [3]
diff.removed; // [2]

// Duration
const Duration(seconds: 30).clamp(Duration.zero, const Duration(seconds: 10)); // 0:00:10.000000

// Future
final task = Future.delayed(const Duration(seconds: 5), () => 'done').cancellable(
  onCancel: () => print('cleanup'),
);
await task.cancel(); // awaiting task now throws TaskCancelledException

await api.fetch().minDuration(const Duration(milliseconds: 300)); // no loader flicker
await api.fetch.retry(period: const Duration(seconds: 1), timeout: const Duration(seconds: 10));

// Any value
12.let((it) => it * 2); // 24
'a'.repeat(3); // [a, a, a]
```

`cancel()` discards the result but does not stop the original future. Stop the underlying
work in `onCancel`.

See [example/](example/) for more.

## Development

Run all CI checks locally: `./scripts/run_ci_locally.sh`. See [LOCAL_CI_TESTING.md](LOCAL_CI_TESTING.md).

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Yobari-Timeliners/caxapok/main/doc/logo-dark.png">
    <img src="https://raw.githubusercontent.com/Yobari-Timeliners/caxapok/main/doc/logo-light.png" alt="caxapok" width="200">
  </picture>
</p>
