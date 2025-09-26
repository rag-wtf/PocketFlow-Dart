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
}

class AddNode extends Node {
  AddNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }
}

class MultiplyNode extends Node {
  MultiplyNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
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
}

void main() {
  group('Flow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('start().run() should execute a single node', () async {
      final pipeline = Flow();
      pipeline.start(NumberNode(5));
      final lastAction = await pipeline.run(sharedStorage);

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

      pipeline.start(startNode).next(checkNode);
      checkNode
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

      pipeline.start(startNode).next(checkNode);
      checkNode
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

      pipeline.start(n1).next(check);
      check
        ..next(subtract3, action: 'positive')
        ..next(endNode, action: 'negative');
      subtract3.next(check);

      final lastAction = await pipeline.run(sharedStorage);

      expect(sharedStorage['current'], -2);
      expect(lastAction, 'cycle_done');
    });
  });
}
