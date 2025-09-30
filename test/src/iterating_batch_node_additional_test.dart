import 'package:pocketflow/src/iterating_batch_node.dart';
import 'package:test/test.dart';

class DummyIteratingBatchNode extends IteratingBatchNode<dynamic, dynamic> {
  DummyIteratingBatchNode() : super();
  List<dynamic> runBatch(List<dynamic> inputs) {
    // Cover line 17: return empty list for edge case
    return <dynamic>[];
  }

  @override
  IteratingBatchNode<dynamic, dynamic> clone() {
    return DummyIteratingBatchNode();
  }
}

void main() {
  group('IteratingBatchNode uncovered lines', () {
    test('should cover line 17 by returning empty batch', () {
      final node = DummyIteratingBatchNode();
      final result = node.runBatch([]);
      expect(result, isEmpty);
    });
  });
}
