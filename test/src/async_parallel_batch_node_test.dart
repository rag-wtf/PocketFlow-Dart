import 'package:pocketflow/src/async_parallel_batch_node.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncParallelBatchNode', () {
    test(
      'should process a batch of inputs and return a batch of outputs '
      'in parallel',
      () async {
        final node = AsyncParallelBatchNode<int, int>(
          (value) => Future.delayed(
            const Duration(milliseconds: 100),
            () => value * 2,
          ),
        );
        final inputs = [1, 2, 3];
        final outputs = await node.call(inputs);
        expect(outputs, equals([2, 4, 6]));
      },
    );

    test('should handle an empty batch', () async {
      final node = AsyncParallelBatchNode<int, int>(
        (value) => Future.value(value * 2),
      );
      final inputs = <int>[];
      final outputs = await node.call(inputs);
      expect(outputs, isEmpty);
    });

    test('should propagate errors for failing futures', () async {
      final node = AsyncParallelBatchNode<int, int>(
        (value) => Future.error('An error occurred'),
      );
      final inputs = [1, 2, 3];
      expect(node.call(inputs), throwsA(isA<String>()));
    });
  });
}
