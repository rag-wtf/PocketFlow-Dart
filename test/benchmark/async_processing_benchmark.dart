import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class AsyncAddNode extends AsyncNode {
  AsyncAddNode()
    : super((params) async {
        await Future<void>.delayed(Duration.zero);
        final p = params as Map<String, dynamic>;
        final a = p['a'] as int;
        final b = p['b'] as int;
        return {'c': a + b};
      });
}

class AsyncBatchAddNode extends AsyncBatchNode<List<int>, List<int>> {
  AsyncBatchAddNode()
    : super((items) async {
        await Future<void>.delayed(Duration.zero);
        final a = items[0];
        final b = items[1];
        final c = <int>[];
        for (var i = 0; i < a.length; i++) {
          c.add(a[i] + b[i]);
        }
        return [c];
      });
}

void main() {
  group('Async Processing Benchmark', () {
    test('AsyncNode Execution', () async {
      final node = AsyncNode((params) async {
        final p = params as Map<String, dynamic>;
        final a = p['a'] as int;
        final b = p['b'] as int;
        return {'c': a + b};
      });
      final stopwatch = Stopwatch()..start();
      const iterations = 10000;

      for (var i = 0; i < iterations; i++) {
        await node.run({'a': i, 'b': i + 1});
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'AsyncNode benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });

    test('AsyncFlow Orchestration', () async {
      final flow = AsyncFlow();
      final add1 = AsyncAddNode()..name = 'add1';
      final add2 = AsyncAddNode()..name = 'add2';
      flow.start(add1).next(add2);

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        await flow.run({
          '__node_params__': {
            'add1': {'a': i, 'b': i + 1},
            'add2': {'a': i + 2, 'b': i + 3},
          },
        });
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'AsyncFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });

    test('AsyncBatchNode Execution', () async {
      final node = AsyncBatchNode<List<int>, List<int>>((items) async {
        final a = items[0];
        final b = items[1];
        final c = <int>[];
        for (var i = 0; i < a.length; i++) {
          c.add(a[i] + b[i]);
        }
        return [c];
      });
      node.params['items'] = [
        List.generate(10, (i) => i),
        List.generate(10, (i) => i + 1),
      ];
      final stopwatch = Stopwatch()..start();
      const iterations = 10000;

      for (var i = 0; i < iterations; i++) {
        await node.run({});
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'AsyncBatchNode benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });

    test('StreamingBatchFlow Orchestration', () async {
      final flow = StreamingBatchFlow<List<int>, List<int>>([
        AsyncBatchAddNode()..name = 'add1',
        AsyncBatchAddNode()..name = 'add2',
      ]);
      flow.params['items'] = [
        List.generate(10, (i) => i),
        List.generate(10, (i) => i + 1),
      ];

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        await flow.run(<String, dynamic>{});
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'StreamingBatchFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });

    test('AsyncParallelBatchFlow Orchestration', () async {
      final flow = AsyncParallelBatchFlow<Map<String, List<int>>, List<int>>([
        AsyncNode((params) async {
          final p = params as Map<String, dynamic>;
          final item = p['input'] as Map<String, List<int>>;
          final a = item['a']!;
          final b = item['b']!;
          final c = <int>[];
          for (var i = 0; i < a.length; i++) {
            c.add(a[i] + b[i]);
          }
          return c;
        })..name = 'add1',
        AsyncNode((params) async {
          final p = params as Map<String, dynamic>;
          final item = p['input'] as Map<String, List<int>>;
          final a = item['a']!;
          final b = item['b']!;
          final c = <int>[];
          for (var i = 0; i < a.length; i++) {
            c.add(a[i] + b[i]);
          }
          return c;
        })..name = 'add2',
      ]);

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;
      final data = [
        {
          'a': List.generate(10, (i) => i),
          'b': List.generate(10, (i) => i + 1),
        },
        {
          'a': List.generate(10, (i) => i + 2),
          'b': List.generate(10, (i) => i + 3),
        },
      ];

      for (var i = 0; i < iterations; i++) {
        await flow.call(data);
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'AsyncParallelBatchFlow benchmark: '
        '${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });
  });
}
