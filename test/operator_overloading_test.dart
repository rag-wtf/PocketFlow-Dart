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

    test('>> operator should be chainable', () {
      final node1 = TestNode();
      final node2 = TestNode();
      final node3 = TestNode();
      final result = node1 >> node2 >> node3;
      expect(result, equals(node3));
      expect(node1.successors['default'], equals(node2));
      expect(node2.successors['default'], equals(node3));
    });

    test('- and >> operators should be chainable', () {
      final nodeA = TestNode();
      final nodeB = TestNode();
      final nodeC = TestNode();
      final result1 = nodeA - 'a' >> nodeB;
      final result2 = nodeB - 'b' >> nodeC;
      expect(result1, equals(nodeB));
      expect(result2, equals(nodeC));
      expect(nodeA.successors['a'], equals(nodeB));
      expect(nodeB.successors['b'], equals(nodeC));
    });
  });
}
