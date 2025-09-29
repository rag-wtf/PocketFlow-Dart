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

// A node that returns a specific signal string from its post method.
class SignalNode extends Node {
  final String signal;
  SignalNode(this.signal);

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['last_signal_emitted'] = signal;
    return signal;
  }

  @override
  BaseNode createInstance() => SignalNode(signal);
}

// A node to indicate which path was taken in the outer flow.
class PathNode extends Node {
  final String pathId;
  PathNode(this.pathId);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['path_taken'] = pathId;
  }

  @override
  BaseNode createInstance() => PathNode(pathId);
}

// --- Test Class ---
void main() {
  group('FlowComposition Parity Tests', () {
    test('Flow as node', () async {
      final sharedStorage = <String, dynamic>{};
      final f1 = Flow(start: NumberNode(5));
      final addNode = AddNode(10);
      final multiplyNode = MultiplyNode(2);
      f1 >> addNode >> multiplyNode;

      final f2 = Flow(start: f1);
      final f3 = Flow(start: f2);

      await f3.run(sharedStorage);
      expect(sharedStorage['current'], 30);
    });

    test('Nested flow', () async {
      final sharedStorage = <String, dynamic>{};
      final n5 = NumberNode(5);
      n5 >> AddNode(3);
      final innerFlow = Flow(start: n5);

      final middleFlow = Flow(start: innerFlow);
      middleFlow >> MultiplyNode(4);

      final wrapperFlow = Flow(start: middleFlow);
      await wrapperFlow.run(sharedStorage);
      expect(sharedStorage['current'], 32);
    });

    test('Flow chaining flows', () async {
      final sharedStorage = <String, dynamic>{};
      final numberNode = NumberNode(10);
      numberNode >> AddNode(10);
      final flow1 = Flow(start: numberNode);

      final flow2 = Flow(start: MultiplyNode(2));

      flow1 >> flow2;

      final wrapperFlow = Flow(start: flow1);
      await wrapperFlow.run(sharedStorage);
      expect(sharedStorage['current'], 40);
    });

    test('Composition with action propagation', () async {
      final sharedStorage = <String, dynamic>{};

      final innerStartNode = NumberNode(100);
      final innerEndNode = SignalNode("inner_done");
      innerStartNode >> innerEndNode;
      final innerFlow = Flow(start: innerStartNode);

      final pathANode = PathNode("A");
      final pathBNode = PathNode("B");

      final outerFlow = Flow(start: innerFlow);

      innerFlow - "inner_done" >> pathBNode;
      innerFlow - "other_action" >> pathANode;

      final lastActionOuter = await outerFlow.run(sharedStorage);

      expect(sharedStorage['current'], 100);
      expect(sharedStorage['last_signal_emitted'], "inner_done");
      expect(sharedStorage['path_taken'], "B");
      expect(lastActionOuter, isNull);
    });
  });
}
