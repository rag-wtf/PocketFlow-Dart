import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A simple implementation of BaseNode for testing.
class TestNode extends BaseNode {
  @override
  BaseNode clone() => TestNode();
}

void main() {
  group('Operator Overloading', () {
    test('>> operator should chain nodes', () {
      final node1 = TestNode();
      final node2 = TestNode();
      final result = node1 >> node2;
      expect(node1.successors['default'], equals(node2));
      expect(result, equals(node2));
    });

    test('- operator should create a conditional transition', () {
      final node1 = TestNode();
      final node2 = TestNode();
      final result = node1 - 'on_success' >> node2;
      expect(node1.successors['on_success'], equals(node2));
      expect(result, equals(node2));
    });
  });
}
