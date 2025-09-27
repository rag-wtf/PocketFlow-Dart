# Quickstart

This document provides a quickstart guide to using the PocketFlow library.

## Basic Usage

```dart
import 'package:pocketflow/pocketflow.dart';

void main() {
  // Create a simple flow
  final node1 = Node(
    name: 'Node 1',
    callable: (params, shared) => {'result': params['input'] * 2},
  );

  final node2 = Node(
    name: 'Node 2',
    callable: (params, shared) => {'result': params['input'] + 1},
  );

  final flow = Flow()
    ..add(node1)
    ..add(node2);

  // Run the flow
  final result = flow.run({'input': 10});

  print(result); // Output: {'result': 21}
}
```

## Conditional Flows

```dart
import 'package:pocketflow/pocketflow.dart';

void main() {
  // Create a conditional flow
  final startNode = Node(
    name: 'Start',
    callable: (params, shared) => {'result': params['input']},
  );

  final evenNode = Node(
    name: 'Even',
    callable: (params, shared) => {'result': 'is even'},
  );

  final oddNode = Node(
    name: 'Odd',
    callable: (params, shared) => {'result': 'is odd'},
  );

  startNode.next(evenNode, condition: (params, shared) => params['input'] % 2 == 0);
  startNode.next(oddNode, condition: (params, shared) => params['input'] % 2 != 0);

  final flow = Flow()..add(startNode);

  // Run the flow
  final result1 = flow.run({'input': 10});
  print(result1); // Output: {'result': 'is even'}

  final result2 = flow.run({'input': 9});
  print(result2); // Output: {'result': 'is odd'}
}
```
