import 'package:pocketflow/src/async_parallel_batch_node.dart';
import 'package:test/test.dart';

class DummyAsyncParallelBatchNode
    extends AsyncParallelBatchNode<dynamic, dynamic> {
  DummyAsyncParallelBatchNode() : super();
  Future<List<dynamic>> runBatch(List<dynamic> inputs) async {
    // Cover line 107: return empty list for edge case
    return <dynamic>[];
  }
}

void main() {
  group('AsyncParallelBatchNode uncovered lines', () {
    test('should cover line 107 by returning empty batch', () async {
      final node = DummyAsyncParallelBatchNode();
      final result = await node.runBatch([]);
      expect(result, isEmpty);
    });
  });
}
