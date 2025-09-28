import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class AddNode extends Node<Map<String, int>> {
  AddNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  void execute(Map<String, int> params) {
    params['c'] = params['a']! + params['b']!;
  }
}

class SubtractNode extends Node<Map<String, int>> {
  SubtractNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  void execute(Map<String, int> params) {
    params['c'] = params['a']! - params['b']!;
  }
}

void main() {
  group('Flow Benchmark', () {
    test('Simple Flow Orchestration', () {
      final flow = Flow(
        nodes: [
          AddNode()..name = 'add1',
          AddNode()..name = 'add2',
          SubtractNode()..name = 'sub1',
        ],
        connections: [
          Connection('add1', 'c', 'sub1', 'a'),
          Connection('add2', 'c', 'sub1', 'b'),
        ],
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 100000;

      for (var i = 0; i < iterations; i++) {
        flow.call({
          'add1': {'a': i, 'b': i + 1},
          'add2': {'a': i + 2, 'b': i + 3},
        });
      }

      stopwatch.stop();
      print(
        'Flow benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });
  });
}
