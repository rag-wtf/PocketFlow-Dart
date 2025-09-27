import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Helper classes for testing, ported from the Python tests.

class NumberNode extends Node {
  NumberNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = number;
  }

  @override
  Node clone() {
    final cloned = NumberNode(number);
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class ParameterNode extends Node {
  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    if (params.containsKey('value')) {
      sharedStorage['output'] = params['value'];
    }
  }

  @override
  Node clone() {
    final cloned = ParameterNode();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class StatefulNode extends Node {
  int _counter = 0;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    _counter++;
    sharedStorage['counter'] = _counter;
  }

  @override
  Node clone() {
    final cloned = StatefulNode();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class AddNode extends Node {
  AddNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }

  @override
  Node clone() {
    final cloned = AddNode(number);
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class MultiplyNode extends Node {
  MultiplyNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
  }

  @override
  Node clone() {
    final cloned = MultiplyNode(number);
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class CheckPositiveNode extends Node {
  @override
  Future<String?> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    if ((sharedStorage['current'] as int? ?? 0) >= 0) {
      return 'positive';
    } else {
      return 'negative';
    }
  }

  @override
  Node clone() {
    final cloned = CheckPositiveNode();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class EndSignalNode extends Node {
  EndSignalNode(this.signal);
  final String signal;

  @override
  Future<String?> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    return signal;
  }

  @override
  Node clone() {
    final cloned = EndSignalNode(signal);
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

// A test node that increments a value and returns it.
class _TestCloneNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    params['value'] = (params['value'] as int) + 1;
    return params;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Return the value from the params so we can check it in tests.
    return execResult['value'];
  }

  @override
  Node clone() {
    final cloned = _TestCloneNode();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

void main() {
  group('Flow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('run() without a start node should throw a StateError', () {
      final pipeline = Flow();
      expect(
        () => pipeline.run(sharedStorage),
        throwsA(isA<StateError>()),
      );
    });

    test('start().run() should execute a single node', () async {
      final pipeline = Flow();
      final lastAction = await (pipeline..start(NumberNode(5))).run(
        sharedStorage,
      );

      expect(sharedStorage['current'], 5);
      expect(lastAction, isNull);
    });

    test('start().next().next() should execute a chain of nodes', () async {
      final pipeline = Flow();
      pipeline.start(NumberNode(5)).next(AddNode(3)).next(MultiplyNode(2));
      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('next() should execute a sequence of nodes', () async {
      final pipeline = Flow();
      final n1 = NumberNode(5);
      final n2 = AddNode(3);
      final n3 = MultiplyNode(2);

      pipeline.start(n1).next(n2).next(n3);
      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('should follow the "positive" branch', () async {
      final pipeline = Flow();
      final startNode = NumberNode(5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      pipeline.start(startNode).next(checkNode)
        ..next(addIfPositive, action: 'positive')
        ..next(addIfNegative, action: 'negative');

      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 15);
      expect(lastAction, isNull);
    });

    test('should follow the "negative" branch', () async {
      final pipeline = Flow();
      final startNode = NumberNode(-5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      pipeline.start(startNode).next(checkNode)
        ..next(addIfPositive, action: 'positive')
        ..next(addIfNegative, action: 'negative');

      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], -25);
      expect(lastAction, isNull);
    });

    test('should cycle until a condition is met and return a signal', () async {
      final pipeline = Flow();
      final n1 = NumberNode(10);
      final check = CheckPositiveNode();
      final subtract3 = AddNode(-3);
      final endNode = EndSignalNode('cycle_done');

      pipeline.start(n1).next(check)
        ..next(subtract3, action: 'positive')
        ..next(endNode, action: 'negative');
      subtract3.next(check);

      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], -2);
      expect(lastAction, 'cycle_done');
    });

    test('should not persist state between runs', () async {
      final pipeline = Flow();
      pipeline.start(StatefulNode());

      // First run
      await pipeline.run(sharedStorage);
      expect(sharedStorage['counter'], 1);

      // Second run
      await pipeline.run(sharedStorage);
      expect(sharedStorage['counter'], 1);
    });

    test('should pass parameters to nodes by name', () async {
      final pipeline = Flow();
      final paramNode = ParameterNode()..name = 'param_node';
      pipeline.start(paramNode);

      sharedStorage['__node_params__'] = {
        'param_node': {'value': 123},
      };

      await pipeline.run(sharedStorage);

      expect(sharedStorage['output'], 123);
      expect(sharedStorage.containsKey('value'), isFalse);
    });
  });

  group('Flow.clone()', () {
    test('should create a deep copy of the graph', () async {
      final nodeA = _TestCloneNode()..params['value'] = 1;
      final nodeB = _TestCloneNode()..params['value'] = 10;
      final nodeC = _TestCloneNode()..params['value'] = 100;

      // Original flow is A -> B
      final originalFlow = Flow();
      originalFlow.start(nodeA).next(nodeB);

      // Clone the flow
      final clonedFlow = originalFlow.clone();

      // Modify the original flow's graph to A -> C
      nodeA.next(nodeC);

      // Run the original flow. It should execute A -> C and return 101.
      var result = await originalFlow.run({});
      expect(result, 101);

      // Run the cloned flow. It should still execute A -> B and return 11.
      result = await clonedFlow.run({});
      expect(result, 11);
    });
  });
}
