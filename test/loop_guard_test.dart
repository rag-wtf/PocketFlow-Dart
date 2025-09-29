import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class LoopingNode extends Node {
  LoopingNode();

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return 'loop'; // Always returns 'loop' action to create infinite loop
  }

  @override
  BaseNode createInstance() => LoopingNode();
}

class CountingNode extends Node {
  CountingNode();
  static int executionCount = 0;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    executionCount++;
    if (executionCount < 3) {
      return 'continue';
    }
    return 'done';
  }

  @override
  BaseNode createInstance() => CountingNode();
}

class EndNode extends Node {
  EndNode();

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return 'done';
  }

  @override
  BaseNode createInstance() => EndNode();
}

void main() {
  group('Flow maxSteps Guard', () {
    test('should prevent infinite loops with maxSteps', () async {
      final loopingNode = LoopingNode();
      loopingNode.next(loopingNode, action: 'loop'); // Self-loop

      final flow = Flow();
      flow.start(loopingNode);

      // Should throw StateError when maxSteps exceeded
      expect(
        () async => flow.orch(<String, dynamic>{}, null, 5),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('exceeded maxSteps limit of 5'),
          ),
        ),
      );
    });

    test('should allow unlimited steps when maxSteps is null', () async {
      CountingNode.executionCount = 0; // Reset counter
      final countingNode = CountingNode();
      final endNode = EndNode();

      countingNode.next(
        countingNode,
        action: 'continue',
      ); // Self-loop for counting
      countingNode.next(endNode, action: 'done'); // Exit condition

      final flow = Flow();
      flow.start(countingNode);

      // Should complete without error (no maxSteps limit)
      final result = await flow.orch(<String, dynamic>{});
      expect(result, equals('done'));
      expect(CountingNode.executionCount, equals(3));
    });

    test('should complete normally when under maxSteps limit', () async {
      CountingNode.executionCount = 0; // Reset counter
      final countingNode = CountingNode();
      final endNode = EndNode();

      countingNode.next(
        countingNode,
        action: 'continue',
      ); // Self-loop for counting
      countingNode.next(endNode, action: 'done'); // Exit condition

      final flow = Flow();
      flow.start(countingNode);

      // Should complete normally with maxSteps=10 (execution needs only 3 steps)
      final result = await flow.orch(
        <String, dynamic>{},
        null,
        10,
      );
      expect(result, equals('done'));
      expect(CountingNode.executionCount, equals(3));
    });

    test('AsyncFlow should also respect maxSteps', () async {
      final loopingNode = LoopingNode();
      loopingNode.next(loopingNode, action: 'loop'); // Self-loop

      final flow = AsyncFlow();
      flow.start(loopingNode);

      // Should throw StateError when maxSteps exceeded
      expect(
        () async => flow.orchAsync(<String, dynamic>{}, null, 3),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('exceeded maxSteps limit of 3'),
          ),
        ),
      );
    });
  });
}
