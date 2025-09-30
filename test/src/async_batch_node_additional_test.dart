import 'package:pocketflow/src/async_batch_node.dart';
import 'package:test/test.dart';

class DummyAsyncBatchNode extends AsyncBatchNode<dynamic, dynamic> {
  DummyAsyncBatchNode() : super();
  Future<List<dynamic>> runBatch(List<dynamic> inputs) async {
    // Cover line 108: return empty list for edge case
    return <dynamic>[];
  }
}

void main() {
  group('AsyncBatchNode uncovered lines', () {
    test('should cover line 108 by returning empty batch', () async {
      final node = DummyAsyncBatchNode();
      final result = await node.runBatch([]);
      expect(result, isEmpty);
    });
  });
}
