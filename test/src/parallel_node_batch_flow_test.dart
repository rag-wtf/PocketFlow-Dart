import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mutable node for testing the deep cloning of the flow.
class _MutableNode extends BaseNode {
  _MutableNode(this.factor);
  int factor;

  @override
  Future<dynamic> run(Map<String, dynamic> shared) async {
    return (shared['input'] as int) * factor;
  }

  @override
  BaseNode clone() {
    return _MutableNode(factor);
  }
}

void main() {
  group('ParallelNodeBatchFlow', () {
    test('should process a batch of inputs in parallel', () async {
      final flow = ParallelNodeBatchFlow<int, int>([
        AsyncNode(
          (dynamic r) async =>
              ((r as Map<String, dynamic>)['input'] as int) * 2,
        ),
        AsyncNode(
          (dynamic r) async =>
              ((r as Map<String, dynamic>)['input'] as int) * 3,
        ),
      ]);

      final result = await flow.call([1, 2, 3]);
      expect(result, [
        [2, 3],
        [4, 6],
        [6, 9],
      ]);
    });

    group('constructor', () {
      test('should throw an ArgumentError if the list of nodes is empty', () {
        expect(
          () => ParallelNodeBatchFlow<int, int>([]),
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
      test('should throw an ArgumentError if "input" key is missing', () {
        final flow = ParallelNodeBatchFlow<int, int>([
          AsyncNode((r) async => 1),
        ]);
        expect(
          () => flow.run({}), // Empty shared map
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'ParallelNodeBatchFlow requires a list of items under the key '
                  '"input" in the shared context. Use the call() method to '
                  'provide the input list.',
            ),
          ),
        );
      });

      test('should throw an ArgumentError if "input" is not a List', () {
        final flow = ParallelNodeBatchFlow<int, int>([
          AsyncNode((r) async => 1),
        ]);
        expect(
          () => flow.run({'input': 'not a list'}), // Input is not a list
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'ParallelNodeBatchFlow requires a list of items under the key '
                  '"input" in the shared context. Use the call() method to '
                  'provide the input list.',
            ),
          ),
        );
      });
    });

    group('clone', () {
      test('should create a deep copy of the flow', () async {
        final originalNode = _MutableNode(2);
        final originalFlow = ParallelNodeBatchFlow<int, dynamic>([
          originalNode,
        ]);

        // Clone the flow. It should have a new node with factor = 2.
        final clonedFlow = originalFlow.clone();

        // Modify the node in the original flow's list.
        originalNode.factor = 10;

        // Run the original flow. It should use the modified factor.
        final originalResult = await originalFlow.call([5]);
        expect(originalResult, [
          [50],
        ]);

        // Run the cloned flow. It should use the original factor.
        final clonedResult = await clonedFlow.call([5]);
        expect(clonedResult, [
          [10],
        ]);
      });
    });
  });
}
