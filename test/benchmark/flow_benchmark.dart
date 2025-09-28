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
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['${name}_c'] = execResult;
    return super.post(shared, prepResult, execResult);
  }

  @override
  Node clone() {
    return AddNode()
      ..name = name
      ..params = Map.from(params);
  }
}

class SubtractNode extends Node {
  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    params['a'] = shared['add1_c'];
    params['b'] = shared['add2_c'];
    return super.prep(shared);
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    final a = params['a'] as int;
    final b = params['b'] as int;
    return a - b;
  }

  @override
  Node clone() {
    return SubtractNode()
      ..name = name
      ..params = Map.from(params);
  }
}

void main() {
  group('Flow Benchmark', () {
    test('Simple Flow Orchestration', () async {
      final flow = Flow();
      final add1 = AddNode()..name = 'add1';
      final add2 = AddNode()..name = 'add2';
      final sub1 = SubtractNode()..name = 'sub1';
      flow.start(add1).next(add2).next(sub1);

      final stopwatch = Stopwatch()..start();
      const iterations = 100000;

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
        'Flow benchmark: ${stopwatch.elapsedMilliseconds}ms for '
        '$iterations iterations',
      );
    });
  });
}
