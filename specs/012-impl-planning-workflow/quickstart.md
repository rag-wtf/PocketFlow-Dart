# Quickstart

This document provides a quick overview of how to use the refactored PocketFlow library.

## Basic Usage

### 1. Define Nodes

```dart
import 'package:pocketflow/pocketflow.dart';

class AddOne extends Node {
  @override
  dynamic exec(dynamic prepResult) {
    return prepResult + 1;
  }
}

class MultiplyByTwo extends Node {
  @override
  dynamic exec(dynamic prepResult) {
    return prepResult * 2;
  }
}
```

### 2. Create a Flow

```dart
void main() {
  final addOne = AddOne();
  final multiplyByTwo = MultiplyByTwo();

  addOne.successors['default'] = multiplyByTwo;

  final flow = Flow();
  flow.startNode = addOne;

  final result = flow.run({'input': 1});
  print(result); // Output: 4
}
```

## Async Usage

### 1. Define Async Nodes

```dart
import 'package:pocketflow/pocketflow.dart';

class AddOneAsync extends AsyncNode {
  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    return prepResult + 1;
  }
}

class MultiplyByTwoAsync extends AsyncNode {
  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    return prepResult * 2;
  }
}
```

### 2. Create an Async Flow

```dart
void main() async {
  final addOne = AddOneAsync();
  final multiplyByTwo = MultiplyByTwoAsync();

  addOne.successors['default'] = multiplyByTwo;

  final flow = AsyncFlow();
  flow.startNode = addOne;

  final result = await flow.runAsync({'input': 1});
  print(result); // Output: 4
}
```
