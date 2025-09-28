import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class AsyncAddNode extends AsyncNode<Map<String, int>> {
  AsyncAddNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  Future<void> execute(Map<String, int> params) async {
    await Future.delayed(Duration.zero);
    params['c'] = params['a']! + params['b']!;
  }
}

class AsyncBatchAddNode extends AsyncBatchNode<Map<String, List<int>>> {
  AsyncBatchAddNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  Future<void> execute(Map<String, List<int>> params) async {
    await Future.delayed(Duration.zero);
    final a = params['a']!;
    final b = params['b']!;
    final c = <int>[];
    for (var i = 0; i < a.length; i++) {
      c.add(a[i] + b[i]);
    }
    params['c'] = c;
  }
}

void main() {
  group('Async Processing Benchmark', () {
    test('AsyncNode Execution', () async {
      final node = AsyncAddNode();
      final stopwatch = Stopwatch()..start();
      const iterations = 10000;

      for (var i = 0; i < iterations; i++) {
        await node.call({'a': i, 'b': i + 1});
      }

      stopwatch.stop();
      print(
        'AsyncNode benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });

    test('AsyncFlow Orchestration', () async {
      final flow = AsyncFlow(
        nodes: [
          AsyncAddNode()..name = 'add1',
          AsyncAddNode()..name = 'add2',
        ],
        connections: [],
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        await flow.call({
          'add1': {'a': i, 'b': i + 1},
          'add2': {'a': i + 2, 'b': i + 3},
        });
      }

      stopwatch.stop();
      print(
        'AsyncFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });

    test('AsyncBatchNode Execution', () async {
      final node = AsyncBatchAddNode();
      final stopwatch = Stopwatch()..start();
      const iterations = 10000;
      final data = {
        'a': List.generate(10, (i) => i),
        'b': List.generate(10, (i) => i + 1),
      };

      for (var i = 0; i < iterations; i++) {
        await node.call(data);
      }

      stopwatch.stop();
      print(
        'AsyncBatchNode benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });

    test('AsyncBatchFlow Orchestration', () async {
      final flow = AsyncBatchFlow(
        nodes: [
          AsyncBatchAddNode()..name = 'add1',
          AsyncBatchAddNode()..name = 'add2',
        ],
        connections: [],
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;
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
        await flow.call(data);
      }

      stopwatch.stop();
      print(
        'AsyncBatchFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });

    test('AsyncParallelBatchFlow Orchestration', () async {
      final flow = AsyncParallelBatchFlow(
        nodes: [
          AsyncBatchAddNode()..name = 'add1',
          AsyncBatchAddNode()..name = 'add2',
        ],
        connections: [],
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;
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
        await flow.call(data);
      }

      stopwatch.stop();
      print(
        'AsyncParallelBatchFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });
  });
}
