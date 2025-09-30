import 'package:pocketflow/src/async_batch_flow.dart';
import 'package:test/test.dart';
import 'async_batch_node_additional_test.dart';

void main() {
  group('AsyncBatchFlow uncovered lines', () {
    test('should cover line 52 by triggering edge case', () async {
      // Create a minimal AsyncBatchFlow with a batch size that triggers
      // the uncovered line
      final flow = AsyncBatchFlow(start: DummyAsyncBatchNode());
      final result = await flow.run({'items': <dynamic>[]});
      expect(result, isEmpty);
    });
  });
}
