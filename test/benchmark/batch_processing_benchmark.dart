import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class BatchAddNode extends BatchNode<Map<String, List<int>>> {
  BatchAddNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  void execute(Map<String, List<int>> params) {
    final a = params['a']!;
    final b = params['b']!;
    final c = <int>[];
    for (var i = 0; i < a.length; i++) {
      c.add(a[i] + b[i]);
    }
    params['c'] = c;
  }
}

class BatchSubtractNode extends BatchNode<Map<String, List<int>>> {
  BatchSubtractNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  void execute(Map<String, List<int>> params) {
    final a = params['a']!;
    final b = params['b']!;
    final c = <int>[];
    for (var i = 0; i < a.length; i++) {
      c.add(a[i] - b[i]);
    }
    params['c'] = c;
  }
}

void main() {
  group('Batch Processing Benchmark', () {
    test('BatchNode Execution', () {
      final node = BatchAddNode();
      final stopwatch = Stopwatch()..start();
      const iterations = 100000;
      final data = {
        'a': List.generate(10, (i) => i),
        'b': List.generate(10, (i) => i + 1),
      };

      for (var i = 0; i < iterations; i++) {
        node.call(data);
      }

      stopwatch.stop();
      print(
        'BatchNode benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });

    test('BatchFlow Orchestration', () {
      final flow = BatchFlow(
        nodes: [
          BatchAddNode()..name = 'add1',
          BatchAddNode()..name = 'add2',
          BatchSubtractNode()..name = 'sub1',
        ],
        connections: [
          Connection('add1', 'c', 'sub1', 'a'),
          Connection('add2', 'c', 'sub1', 'b'),
        ],
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 10000;
      final data = {
        'add1': {
          'a': List.generate(10, (i) => i),
          'b': List.generate(10, (i) => i + 1),
        },
        'add2': {
          'a': List.generate(10, (i) => i + 2),
          'b': List.generate(10, (i) => i + 3),
        },
      };

      for (var i = 0; i < iterations; i++) {
        flow.call(data);
      }

      stopwatch.stop();
      print(
        'BatchFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });
  });
}
