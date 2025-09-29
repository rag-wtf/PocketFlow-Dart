# PocketFlow Dart Extensions

This document describes the Dart-specific extensions available in the `pocketflow_extensions.dart` library. These extensions are **not part of the core Python PocketFlow runtime** but provide additional convenience classes and patterns that leverage Dart's type system and language features.

## Overview

The extensions library provides three main classes that complement the core PocketFlow functionality:

- **`IteratingBatchNode`** - Automatic iteration over batch items with per-item retry logic
- **`ParallelNodeBatchFlow`** - Parallel execution of multiple nodes for each batch item  
- **`StreamingBatchFlow`** - Sequential batch processing through a pipeline of nodes

## Usage

To use the extensions, import the extensions library:

```dart
import 'package:pocketflow/pocketflow_extensions.dart';
```

This automatically includes all core PocketFlow classes plus the extensions.

## Extension Classes

### IteratingBatchNode<I, O>

A convenience class that automatically iterates over a batch of items, applying the same operation to each item individually. This mirrors the Python `BatchNode` behavior with per-item retry logic.

**Key Features:**
- Automatic iteration over batch items
- Per-item retry logic (inherited from `Node`)
- Type-safe input/output handling
- Retrieves items from either `params['items']` or `shared['items']`

**Example:**

```dart
class DoubleNode extends IteratingBatchNode<int, int> {
  @override
  Future<int> exec(int item) async {
    return item * 2;
  }

  @override
  IteratingBatchNode<int, int> clone() {
    return DoubleNode()
      ..name = name
      ..params = Map.from(params);
  }
}

// Usage
final node = DoubleNode();
node.params['items'] = [1, 2, 3, 4];

final result = await node.run({});
print(result); // [2, 4, 6, 8]
```

### ParallelNodeBatchFlow<TIn, TOut>

A flow that executes multiple nodes in parallel for each item in a batch. This is useful when you need to perform multiple independent operations on each item.

**Key Features:**
- Parallel execution of nodes for each batch item
- Deep cloning ensures state isolation
- Type-safe batch processing
- Convenient `call()` method for direct usage

**Example:**

```dart
final flow = ParallelNodeBatchFlow<int, dynamic>([
  SimpleAsyncNode((dynamic input) async {
    final item = (input as Map<String, dynamic>)['input'] as int;
    return item * 2; // Double the input
  }),
  SimpleAsyncNode((dynamic input) async {
    final item = (input as Map<String, dynamic>)['input'] as int;
    return item + 10; // Add 10 to the input
  }),
]);

// Process batch [1, 2, 3]
final result = await flow.call([1, 2, 3]);
print(result); 
// [
//   [2, 11],   // Results for item 1: [1*2, 1+10]
//   [4, 12],   // Results for item 2: [2*2, 2+10]  
//   [6, 13],   // Results for item 3: [3*2, 3+10]
// ]
```

### StreamingBatchFlow<TIn, TOut>

A flow that processes a batch sequentially through a pipeline of nodes, where each node receives and modifies the entire batch before passing it to the next node.

**Key Features:**
- Sequential pipeline processing
- Each node processes the entire batch
- Automatic chaining of nodes
- Batch flows through the pipeline as a stream

**Example:**

```dart
// Node that doubles all items in a batch
final doubleNode = AsyncBatchNode<int, int>((items) async {
  return items.map((i) => i * 2).toList();
});

// Node that adds 1 to all items in a batch  
final addOneNode = AsyncBatchNode<int, int>((items) async {
  return items.map((i) => i + 1).toList();
});

final flow = StreamingBatchFlow<int, int>([doubleNode, addOneNode]);
flow.params['items'] = [1, 2, 3];

final result = await flow.run({});
print(result); // [3, 5, 7] (doubled then incremented)
```

## Core vs Extensions

### Core Classes (Python Parity)
These classes mirror the Python PocketFlow implementation:
- `BaseNode`, `Node`, `Flow`
- `AsyncNode`, `AsyncFlow`  
- `BatchNode`, `BatchFlow`
- `AsyncBatchNode`, `AsyncBatchFlow`
- `AsyncParallelBatchNode`, `AsyncParallelBatchFlow`

### Extension Classes (Dart-Specific)
These classes provide additional patterns not found in Python:
- `IteratingBatchNode` - Per-item processing with automatic iteration
- `ParallelNodeBatchFlow` - Multi-node parallel processing per item
- `StreamingBatchFlow` - Pipeline-style batch processing

## When to Use Extensions

**Use `IteratingBatchNode` when:**
- You need to process each item in a batch individually
- You want per-item retry logic
- You're migrating from Python `BatchNode` patterns

**Use `ParallelNodeBatchFlow` when:**
- You need to run multiple independent operations on each batch item
- You want to maximize parallelism across both items and operations
- You have CPU-intensive operations that can benefit from parallel execution

**Use `StreamingBatchFlow` when:**
- You need to process batches through a pipeline of transformations
- Each transformation should see the entire batch
- You want to chain multiple batch operations sequentially

## Migration from Core Classes

If you're currently using the core classes and want to leverage extensions:

```dart
// Before: Using core AsyncBatchFlow
final flow = AsyncBatchFlow([node1, node2]);

// After: Using StreamingBatchFlow extension  
final flow = StreamingBatchFlow([node1, node2]);
```

The extensions provide more specialized behavior while maintaining compatibility with the core PocketFlow patterns.
