import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class AddNode extends Node<Map<String, int>> {
  AddNode() : super(inputs: ['a', 'b'], outputs: ['c']);

  @override
  void execute(Map<String, int> params) {
    params['c'] = params['a']! + params['b']!;
  }
}

void main() {
  group('Node Benchmark', () {
    test('Simple Node Execution', () {
      final node = AddNode();
      final stopwatch = Stopwatch()..start();
      const iterations = 1000000;

      for (var i = 0; i < iterations; i++) {
        node.call({'a': i, 'b': i + 1});
      }

      stopwatch.stop();
      print(
        'Node benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations',
      );
    });
  });
}
