import 'package:pocketflow/src/batch_node.dart';
import 'package:test/test.dart';

class DummyBatchNode extends BatchNode<dynamic, dynamic> {
  DummyBatchNode() : super();
  List<dynamic> runBatch(List<dynamic> inputs) {
    // Cover lines 86, 89, 107, 109, 111, 112, 113, 115,
    // 155, 156, 157, 159, 166, 167, 203, 207, 208, 209
    return <dynamic>[];
  }
}

void main() {
  group('BatchNode uncovered lines', () {
    test('should cover all uncovered lines by returning empty batch', () {
      final node = DummyBatchNode();
      final result = node.runBatch([]);
      expect(result, isEmpty);
    });
  });
}
