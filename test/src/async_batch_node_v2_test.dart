import 'package:pocketflow/src/base_node.dart';
import 'package:pocketflow/src/batch_node.dart';
import 'package:test/test.dart';

// A test implementation of InheritanceAsyncBatchNode
class MultiplyAsyncBatchNode extends InheritanceAsyncBatchNode<int, int> {
  MultiplyAsyncBatchNode(this.factor);

  final int factor;

  // Override execItemAsync to process individual items
  @override
  Future<int?> execItemAsync(int item) async {
    return item * factor;
  }

  @override
  BaseNode createInstance() {
    return MultiplyAsyncBatchNode(factor);
  }

  @override
  MultiplyAsyncBatchNode clone() {
    return super.clone() as MultiplyAsyncBatchNode;
  }
}

void main() {
  group('AsyncBatchNode', () {
    test('should process a batch of items using inheritance pattern', () async {
      final node = MultiplyAsyncBatchNode(3);
      node.params['items'] = [1, 2, 3, 4, 5];

      final result = await node.runAsync(<String, dynamic>{});
      expect(result, equals([3, 6, 9, 12, 15]));
    });

    test('should handle empty batch', () async {
      final node = MultiplyAsyncBatchNode(2);
      node.params['items'] = <int>[];

      final result = await node.runAsync(<String, dynamic>{});
      expect(result, equals(<int>[]));
    });

    test('should retrieve items from shared storage', () async {
      final node = MultiplyAsyncBatchNode(4);
      final shared = <String, dynamic>{
        'items': [10, 20, 30],
      };

      final result = await node.runAsync(shared);
      expect(result, equals([40, 80, 120]));
    });

    test('should throw ArgumentError if items parameter is missing', () async {
      final node = MultiplyAsyncBatchNode(5);

      expect(
        () => node.runAsync(<String, dynamic>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should clone correctly', () {
      final node = MultiplyAsyncBatchNode(7)
        ..name = 'TestNode'
        ..params['items'] = [1, 2, 3];

      final cloned = node.clone();

      expect(cloned, isA<MultiplyAsyncBatchNode>());
      expect(cloned.factor, equals(7));
      expect(cloned.name, equals('TestNode'));
      expect(cloned.params['items'], equals([1, 2, 3]));
      expect(cloned, isNot(same(node)));
    });

    test('should use default execItemAsync when not overridden', () async {
      final node = InheritanceAsyncBatchNode<int, int>();
      node.params['items'] = [1, 2, 3];

      // Default implementation returns null for all items, so result should be
      // empty
      final result = await node.runAsync(<String, dynamic>{});
      expect(result, equals(<int>[]));
    });
  });
}
