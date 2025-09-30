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
  BaseNode createInstance() {
    return MultiplyNode(factor);
  }

  @override
  MultiplyNode clone() {
    return super.clone() as MultiplyNode;
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
      final shared = <String, dynamic>{'items': inputs};
      final outputs = await flow.run(shared);

      // Python parity: BatchFlow returns post(..., exec_res=null)
      expect(outputs, isNull);

      // Verify the flow processed all items by checking final shared state
      expect(shared['value'], equals(7)); // Last processed value: ((3 * 2) + 1)
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
      final originalShared = <String, dynamic>{
        'items': [10, 20],
      };
      final originalOutput = await originalFlow.run(originalShared);
      // Python parity: BatchFlow returns post(..., exec_res=null)
      expect(originalOutput, isNull);
      expect(originalShared['value'], equals(25)); // Last processed: 20 + 5

      // Run cloned flow, should use the original value
      final clonedShared = <String, dynamic>{
        'items': [10, 20],
      };
      final clonedOutput = await clonedFlow.run(clonedShared);
      expect(clonedOutput, isNull);
      expect(clonedShared['value'], equals(21)); // Last processed: 20 + 1
    });
  });
}
