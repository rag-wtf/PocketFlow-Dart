import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// --- Node Definitions ---

class NumberNode extends Node {
  final int number;
  NumberNode(this.number);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = number;
  }

  @override
  BaseNode createInstance() => NumberNode(number);
}

class AddNode extends Node {
  final int number;
  AddNode(this.number);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }

  @override
  BaseNode createInstance() => AddNode(number);
}

class MultiplyNode extends Node {
  final int number;
  MultiplyNode(this.number);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
  }

  @override
  BaseNode createInstance() => MultiplyNode(number);
}

class CheckPositiveNode extends Node {
  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    if ((sharedStorage['current'] as int? ?? 0) >= 0) {
      return 'positive';
    } else {
      return 'negative';
    }
  }

  @override
  BaseNode createInstance() => CheckPositiveNode();
}

class NoOpNode extends Node {
  @override
  BaseNode createInstance() => NoOpNode();
}

class EndSignalNode extends Node {
  final String signal;
  EndSignalNode({this.signal = "finished"});

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    return signal;
  }

  @override
  BaseNode createInstance() => EndSignalNode(signal: signal);
}

// --- Test Class ---
void main() {
  group('FlowBasic Parity Tests', () {
    test('Start method initialization', () async {
      final sharedStorage = <String, dynamic>{};
      final n1 = NumberNode(5);
      final pipeline = Flow(start: n1);
      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 5);
      expect(lastAction, isNull);
    });

    test('Start method chaining', () async {
      final sharedStorage = <String, dynamic>{};
      final pipeline = Flow();
      pipeline.start(NumberNode(5)).next(AddNode(3)).next(MultiplyNode(2));
      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('Sequence with rshift', () async {
      final sharedStorage = <String, dynamic>{};
      final n1 = NumberNode(5);
      final n2 = AddNode(3);
      final n3 = MultiplyNode(2);

      final pipeline = Flow(start: n1);
      n1 >> n2 >> n3;

      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('Branching positive', () async {
      final sharedStorage = <String, dynamic>{};
      final startNode = NumberNode(5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      final pipeline = Flow(start: startNode);
      startNode >> checkNode;
      checkNode - 'positive' >> addIfPositive;
      checkNode - 'negative' >> addIfNegative;

      final lastAction = await pipeline.run(sharedStorage);
      expect(sharedStorage['current'], 15); // 5 + 10
      expect(lastAction, isNull);
    });

    test('Branching negative', () async {
      final sharedStorage = <String, dynamic>{};
      final startNode = NumberNode(-5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      final pipeline = Flow(start: startNode);
      startNode >> checkNode;
      checkNode - 'positive' >> addIfPositive;
      checkNode - 'negative' >> addIfNegative;

      final lastAction = await pipeline.run(sharedStorage);
      expect(sharedStorage['current'], -25); // -5 + -20
      expect(lastAction, isNull);
    });

    test('Cycle until negative ends with signal', () async {
      final sharedStorage = <String, dynamic>{};
      final n1 = NumberNode(10);
      final check = CheckPositiveNode();
      final subtract3 = AddNode(-3);
      final endNode = EndSignalNode(signal: "cycle_done");

      final pipeline = Flow(start: n1);
      n1 >> check;
      check - 'positive' >> subtract3;
      check - 'negative' >> endNode;
      subtract3 >> check;

      final lastAction = await pipeline.run(sharedStorage);
      expect(sharedStorage['current'], -2); // 10 -> 7 -> 4 -> 1 -> -2
      expect(lastAction, "cycle_done");
    });

    test('Flow ends warning default missing', () async {
      final sharedStorage = <String, dynamic>{};
      final logs = <String>[];

      final startNode = _ActionNode(null)..log = logs.add;
      final nextNode = NoOpNode();

      final pipeline = Flow(start: startNode);
      startNode - "specific_action" >> nextNode;

      final lastAction = await pipeline.run(sharedStorage);

      expect(logs.length, 1);
      expect(
        logs.first,
        contains("Warning: Flow ends: 'null' not found in [specific_action]"),
      );
      expect(lastAction, isNull);
    });

    test('Flow ends warning specific missing', () async {
      final sharedStorage = <String, dynamic>{};
      final logs = <String>[];

      final startNode = _ActionNode("specific_action")..log = logs.add;
      final nextNode = NoOpNode();

      final pipeline = Flow(start: startNode);
      startNode >> nextNode;

      final lastAction = await pipeline.run(sharedStorage);

      expect(logs.length, 1);
      expect(
        logs.first,
        contains(
          "Warning: Flow ends: 'specific_action' not found in [default]",
        ),
      );
      expect(lastAction, "specific_action");
    });
  });
}

class _ActionNode extends Node {
  final String? _action;
  _ActionNode(this._action);

  @override
  Future<dynamic> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    return _action;
  }

  @override
  BaseNode createInstance() => _ActionNode(_action);
}
