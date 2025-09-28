import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class BatchAddNode extends BatchNode<List<int>, List<int>> {
  @override
  Future<List<List<int>>> exec(List<List<int>> items) async {
    final a = items[0];
    final b = items[1];
    final c = <int>[];
    for (var i = 0; i < a.length; i++) {
      c.add(a[i] + b[i]);
    }
    return [c];
  }

  @override
  BatchAddNode clone() {
    return BatchAddNode()
      ..name = name
      ..params = Map.from(params);
  }
}

void main() {
  group('Batch Processing Benchmark', () {
    test('BatchNode Execution', () async {
      final node = BatchAddNode();
      node.params['items'] = [
        List.generate(10, (i) => i),
        List.generate(10, (i) => i + 1),
      ];
      final stopwatch = Stopwatch()..start();
      const iterations = 100000;

      for (var i = 0; i < iterations; i++) {
        await node.run({});
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'BatchNode benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });

    test('BatchFlow Orchestration', () async {
      final flow = BatchFlow<List<List<int>>, List<List<int>>>([
        BatchAddNode()..name = 'add1',
        BatchAddNode()..name = 'add2',
      ]);
      final stopwatch = Stopwatch()..start();
      const iterations = 10000;
      final data = [
        List.generate(10, (i) => i),
        List.generate(10, (i) => i + 1),
      ];

      for (var i = 0; i < iterations; i++) {
        await flow.run({
          'items': [data],
        });
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'BatchFlow benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });
  });
}
