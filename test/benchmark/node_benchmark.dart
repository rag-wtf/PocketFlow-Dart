import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class AddNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    final a = params['a'] as int;
    final b = params['b'] as int;
    return a + b;
  }

  @override
  Node clone() {
    return AddNode()
      ..name = name
      ..params = Map.from(params);
  }
}

void main() {
  group('Node Benchmark', () {
    test('Simple Node Execution', () async {
      final node = AddNode();
      final stopwatch = Stopwatch()..start();
      const iterations = 1000000;

      for (var i = 0; i < iterations; i++) {
        node.params['a'] = i;
        node.params['b'] = i + 1;
        await node.run({});
      }

      stopwatch.stop();
      // Benchmarks are not part of the application, so printing to the console
      // is acceptable.
      // ignore: avoid_print
      print(
        'Node benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });
  });
}
