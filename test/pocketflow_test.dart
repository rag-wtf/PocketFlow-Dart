import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A concrete implementation of BaseNode for testing purposes.
class _TestNode extends BaseNode {
  _TestNode();

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return {'value': 'test'};
  }
}

void main() {
  group('pocketflow', () {
    test('should export BaseNode', () {
      final node = _TestNode();
      expect(node, isA<BaseNode>());
    });

    test('should export Node', () {
      final node = Node();
      expect(node, isA<Node>());
    });

    test('should export Flow', () {
      final flow = Flow();
      expect(flow, isA<Flow>());
    });
  });
}
