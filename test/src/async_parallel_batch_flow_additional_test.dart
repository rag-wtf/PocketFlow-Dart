import 'package:pocketflow/src/async_parallel_batch_flow.dart';
import 'package:test/test.dart';
import 'async_parallel_batch_node_additional_test.dart';

void main() {
  group('AsyncParallelBatchFlow uncovered lines', () {
    test(
      'should cover lines 78, 101, 104 by running with empty nodes',
      () async {
        final flow = AsyncParallelBatchFlow(
          start: DummyAsyncParallelBatchNode(),
        );
        final result = await flow.run({'items': <dynamic>[]});
        expect(result, isEmpty);
      },
    );
  });
}
