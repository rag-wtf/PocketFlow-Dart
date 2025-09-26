import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Helper classes for testing, ported from the Python tests.

class NumberNode extends Node {
  NumberNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = number;
  }
}

class AddNode extends Node {
  AddNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }
}

class MultiplyNode extends Node {
  MultiplyNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
  }
}

class CheckPositiveNode extends Node {
  @override
  String? post(Map<String, dynamic> sharedStorage, dynamic prepResult) {
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
  String? post(Map<String, dynamic> sharedStorage, dynamic prepResult) {
    return signal;
  }
}

void main() {
  group('Flow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('start().run() should execute a single node', () {
      final pipeline = Flow();
      pipeline.start(NumberNode(5));
      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 5);
      expect(lastAction, isNull);
    });

    test('start().next().next() should execute a chain of nodes', () {
      final pipeline = Flow();
      pipeline.start(NumberNode(5)).next(AddNode(3)).next(MultiplyNode(2));
      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('>> operator should execute a sequence of nodes', () {
      final pipeline = Flow();
      final n1 = NumberNode(5);
      final n2 = AddNode(3);
      final n3 = MultiplyNode(2);

      // The `>>` operator is used for chaining, which is a key feature being
      // tested. This line is essential for verifying the operator's
      // functionality, so the `unnecessary_statements` warning is ignored.
      // ignore: unnecessary_statements
      pipeline.start(n1) >> n2 >> n3;
      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 16);
      expect(lastAction, isNull);
    });

    test('should follow the "positive" branch', () {
      final pipeline = Flow();
      final startNode = NumberNode(5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      pipeline.start(startNode).next(checkNode);
      checkNode.on('positive').next(addIfPositive);
      checkNode.on('negative').next(addIfNegative);

      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], 15);
      expect(lastAction, isNull);
    });

    test('should follow the "negative" branch', () {
      final pipeline = Flow();
      final startNode = NumberNode(-5);
      final checkNode = CheckPositiveNode();
      final addIfPositive = AddNode(10);
      final addIfNegative = AddNode(-20);

      pipeline.start(startNode).next(checkNode);
      checkNode.on('positive').next(addIfPositive);
      checkNode.on('negative').next(addIfNegative);

      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], -25);
      expect(lastAction, isNull);
    });

    test('should cycle until a condition is met and return a signal', () {
      final pipeline = Flow();
      final n1 = NumberNode(10);
      final check = CheckPositiveNode();
      final subtract3 = AddNode(-3);
      final endNode = EndSignalNode('cycle_done');

      pipeline.start(n1).next(check);
      check.on('positive').next(subtract3);
      check.on('negative').next(endNode);
      subtract3.next(check);

      final lastAction = pipeline.run(sharedStorage);

      expect(sharedStorage['current'], -2);
      expect(lastAction, 'cycle_done');
    });
  });
}
