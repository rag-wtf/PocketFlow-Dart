import 'package:pocketflow/src/batch_node.dart';
import 'package:test/test.dart';

// A test node that processes individual items by overriding the parent's exec
class MultiplyBatchNode extends BatchNode<int, int> {
  MultiplyBatchNode(this.factor);

  final int factor;

  // Override the execItem method to process individual items
  @override
  Future<int?> execItem(int item) async {
    return item * factor;
  }

  @override
  MultiplyBatchNode clone() {
    return MultiplyBatchNode(factor)
      ..name = name
      ..params = Map<String, dynamic>.from(params);
  }
}

void main() {
  group('Concrete BatchNode', () {
    test('should use default batch implementation', () async {
      final node = BatchNode<int, int>();
      node.params['items'] = [1, 2, 3, 4, 5];

      // The default implementation calls super.exec() for each item
      // Since BaseNode.exec() returns null, we expect nulls to be filtered out
      final result = await node.run(<String, dynamic>{});
      expect(result, equals(<int>[])); // All nulls filtered out
    });

    test('should work with custom exec implementation', () async {
      final node = MultiplyBatchNode(3);
      node.params['items'] = [1, 2, 3, 4, 5];

      final result = await node.run(<String, dynamic>{});
      expect(result, equals([3, 6, 9, 12, 15]));
    });

    test('should handle empty list', () async {
      final node = MultiplyBatchNode(2);
      node.params['items'] = <int>[];

      final result = await node.run(<String, dynamic>{});
      expect(result, equals(<int>[]));
    });

    test('should retrieve items from shared storage', () async {
      final node = MultiplyBatchNode(4);
      final shared = <String, dynamic>{
        'items': [2, 3, 4],
      };

      final result = await node.run(shared);
      expect(result, equals([8, 12, 16]));
    });

    test('should clone correctly', () {
      final node = MultiplyBatchNode(5)
        ..name = 'TestMultiply'
        ..params['items'] = [1, 2];

      final cloned = node.clone();

      expect(cloned, isA<MultiplyBatchNode>());
      expect(cloned.factor, equals(5));
      expect(cloned.name, equals('TestMultiply'));
      expect(cloned.params['items'], equals([1, 2]));
      expect(cloned, isNot(same(node)));
    });
  });
}
