import 'package:pocketflow/src/base_node.dart';
import 'package:pocketflow/src/iterating_batch_node.dart';
import 'package:test/test.dart';

// A concrete implementation of IteratingBatchNode for testing.
class _TestIteratingNode extends IteratingBatchNode<int, String> {
  @override
  Future<String> exec(int item) async {
    return 'item-$item';
  }

  @override
  IteratingBatchNode<int, String> clone() {
    return _TestIteratingNode()..params.addAll(params);
  }

  @override
  BaseNode createInstance() {
    return _TestIteratingNode();
  }
}

void main() {
  group('IteratingBatchNode', () {
    test('run should process a batch of items by iterating over them',
        () async {
      final node = _TestIteratingNode();
      node.params['items'] = [1, 2, 3];

      final result = await node.run(<String, dynamic>{});
      expect(result, equals(['item-1', 'item-2', 'item-3']));
    });

    test('should throw ArgumentError if "items" is missing', () {
      final node = _TestIteratingNode();
      expect(
        () => node.run(<String, dynamic>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw ArgumentError if "items" is not a List', () {
      final node = _TestIteratingNode();
      node.params['items'] = 'not-a-list';
      expect(
        () => node.run(<String, dynamic>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'should throw ArgumentError if "items" has wrong element types',
        () {
      final node = _TestIteratingNode();
      node.params['items'] = <dynamic>['a', 'b', 'c'];
      expect(
        () => node.run(<String, dynamic>{}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle an empty list of items', () async {
      final node = _TestIteratingNode();
      node.params['items'] = <int>[];

      final result = await node.run(<String, dynamic>{});
      expect(result, isEmpty);
    });

    test('clone should create a new instance with the same properties',
        () async {
      final node = _TestIteratingNode();
      node.name = 'original';
      node.params['items'] = [1];

      final cloned = node.clone();

      expect(cloned, isNot(same(node)));
      expect(cloned.params['items'], equals([1]));
    });

    test(
        'should retrieve items from shared storage if not available in params',
        () async {
      final node = _TestIteratingNode();
      final shared = <String, dynamic>{
        'items': [1, 2, 3]
      };
      final result = await node.run(shared);
      expect(result, equals(['item-1', 'item-2', 'item-3']));
    });

    test('prep should handle a List<dynamic> with correct item types',
        () async {
      final node = _TestIteratingNode();
      final shared = <String, dynamic>{
        'items': <dynamic>[1, 2, 3],
      };
      final result = await node.prep(shared);
      expect(result, isA<List<int>>());
    });
  });
}