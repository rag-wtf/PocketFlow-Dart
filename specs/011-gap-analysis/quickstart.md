# Quickstart

This document provides a quick overview of how to use the new and renamed classes in the PocketFlow-Dart library.

## `StreamingBatchFlow` (formerly `AsyncBatchFlow`)

This flow executes the entire flow once, passing the entire batch of items into the `shared` context. It is ideal for high-performance batch processing where the nodes are designed to handle batches.

```dart
import 'package:pocketflow/pocketflow.dart';

void main() async {
  final flow = StreamingBatchFlow([
    MyBatchNode(),
  ]);

  final result = await flow.run([1, 2, 3]);
  print(result);
}
```

## `AsyncBatchFlow` (New)

This flow iterates through a list of items and executes the entire flow for each item. This is useful when you want to reuse a flow designed for single items to process a batch of items.

```dart
import 'package:pocketflow/pocketflow.dart';

void main() async {
  final flow = AsyncBatchFlow([
    MySingleItemNode(),
  ]);

  final result = await flow.run([1, 2, 3]);
  print(result);
}
```

## `ParallelNodeBatchFlow` (formerly `AsyncParallelBatchFlow`)

For each item, this flow executes the nodes within the flow in parallel. This is useful for reducing the latency of processing a single item by running its internal steps concurrently.

```dart
import 'package:pocketflow/pocketflow.dart';

void main() async {
  final flow = ParallelNodeBatchFlow([
    MyParallelNode1(),
    MyParallelNode2(),
  ]);

  final result = await flow.run([1, 2, 3]);
  print(result);
}
```

## `AsyncParallelBatchFlow` (New)

This flow executes the entire flow in parallel for each item in a batch. This is useful for increasing the throughput of processing many items by running the entire workflow for each item in parallel.

```dart
import 'package:pocketflow/pocketflow.dart';

void main() async {
  final flow = AsyncParallelBatchFlow([
    MySingleItemNode(),
  ]);

  final result = await flow.run([1, 2, 3]);
  print(result);
}
```

## `IteratingBatchNode` (New)

This is an abstract class that automatically iterates over a batch and applies a single-item `execItem` method with per-item retry logic.

```dart
import 'package:pocketflow/pocketflow.dart';

class MyIteratingNode extends IteratingBatchNode<int, int> {
  @override
  Future<int> execItem(int item) async {
    return item * 2;
  }
}
```
