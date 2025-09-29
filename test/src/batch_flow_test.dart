import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class MultiplyNode extends Node {
  MultiplyNode(this.factor);
  final int factor;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared['value'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return (prepResult as int) * factor;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['value'] = execResult;
    return execResult;
  }

  @override
  Node clone() {
    return MultiplyNode(factor)..params = Map.from(params);
  }
}

class AddNode extends Node {
  AddNode(this.valueToAdd);
  int valueToAdd;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared['value'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return (prepResult as int) + valueToAdd;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['value'] = execResult;
    return execResult;
  }

  @override
  Node clone() {
    return AddNode(valueToAdd)..params = Map.from(params);
  }
}

void main() {
  group('BatchFlow', () {
    test('should run a flow over a batch of inputs', () async {
      final multiplyNode = MultiplyNode(2);
      final addNode = AddNode(1);

      final flow = BatchFlow<int, int>([multiplyNode, addNode]);
      final inputs = [1, 2, 3];
      final outputs = await flow.run({'items': inputs});

      expect(outputs, equals([3, 5, 7]));
    });

    group('constructor', () {
      test('should throw an error if the list of nodes is empty', () {
        expect(
          () => BatchFlow<int, int>([]),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'The list of nodes cannot be empty.',
            ),
          ),
        );
      });
    });

    group('run', () {
      test('should throw an error if "items" key is missing', () async {
        final flow = BatchFlow<int, int>([AddNode(1)]);
        expect(
          () => flow.run({}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'BatchFlow requires a list of items under the key "items".',
            ),
          ),
        );
      });

      test('should throw an error if "items" is not a list', () async {
        final flow = BatchFlow<int, int>([AddNode(1)]);
        expect(
          () => flow.run({'items': 'not a list'}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'BatchFlow requires a list of items under the key "items".',
            ),
          ),
        );
      });
    });

    test('clone should create a deep copy of the flow', () async {
      final originalNode = AddNode(1);
      final originalFlow = BatchFlow<int, int>([originalNode]);

      final clonedFlow = originalFlow.clone();
      expect(clonedFlow, isNot(same(originalFlow)));

      // Modify the original node's state
      originalNode.valueToAdd = 5;

      // Run original flow, should use the modified value
      final originalOutput = await originalFlow.run({
        'items': [10, 20],
      });
      expect(originalOutput, equals([15, 25]));

      // Run cloned flow, should use the original value
      final clonedOutput = await clonedFlow.run({
        'items': [10, 20],
      });
      expect(clonedOutput, equals([11, 21]));
    });
  });
}
