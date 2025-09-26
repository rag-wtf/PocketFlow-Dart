# Quickstart

This guide demonstrates a simple use case of the PocketFlow library.

## 1. Add Dependency

```yaml
pocketflow:
  path: ../
```

## 2. Create Nodes

```dart
import 'package:pocketflow/pocketflow.dart';

class AddNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    final a = params['a'] as int;
    final b = params['b'] as int;
    return a + b;
  }
}

class PrintNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    print(prepResult);
    return null;
  }
}
```

## 3. Create and Run a Flow

```dart
void main() async {
  final addNode = AddNode();
  final printNode = PrintNode();

  addNode.next(printNode);

  final flow = Flow(start: addNode);
  flow.setParams({'a': 5, 'b': 10});

  await flow.run({}); // Should print 15
}

```
