import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Test implementation of BaseNode for testing
class TestNode extends BaseNode<String> {
  @override
  String? exec(dynamic prepRes) {
    return 'test_result';
  }
}

void main() {
  group('PocketFlow Library', () {
    test('can import and use BaseNode', () {
      final node = TestNode();
      expect(node, isNotNull);
      expect(node.params, isEmpty);
    });

    test('can import and use Flow', () {
      final flow = Flow<String>();
      expect(flow, isNotNull);
      expect(flow.startNode, isNull);
    });
  });
}
