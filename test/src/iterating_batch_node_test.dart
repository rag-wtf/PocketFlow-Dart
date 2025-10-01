import 'package:pocketflow/pocketflow_extensions.dart';
import 'package:test/test.dart';

// A mock implementation of IteratingBatchNode to test its functionalities.
class MockIteratingBatchNode extends IteratingBatchNode<int, int> {
  bool execCalled = false;
  List<int> receivedItems = [];

  @override
  Future<int> exec(int item) async {
    execCalled = true;
    receivedItems.add(item);
    return item * 2;
  }

  @override
  BaseNode createInstance() {
    return MockIteratingBatchNode();
  }

  @override
  MockIteratingBatchNode clone() {
    return super.clone() as MockIteratingBatchNode;
  }
}

void main() {
  group('IteratingBatchNode', () {
    late MockIteratingBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockIteratingBatchNode();
      sharedStorage = {};
    });

    test(
      'run should process a batch of items by iterating over them',
      () async {
        final items = [1, 2, 3];
        node.params['items'] = items; // Pass items to the node

        final result = await node.run(sharedStorage);

        expect(node.execCalled, isTrue, reason: 'exec should be called');
        expect(
          node.receivedItems,
          equals(items),
          reason: 'exec should be called for each item in the list',
        );
        expect(
          result,
          equals([2, 4, 6]),
          reason: 'run should return the processed items',
        );
      },
    );

    test(
      'run should throw ArgumentError if "items" parameter is missing',
      () async {
        // Intentionally not setting the 'items' parameter
        expect(
          () => node.run(sharedStorage),
          throwsArgumentError,
          reason: 'Should throw ArgumentError when items are null',
        );
      },
    );

    test(
      'run should throw ArgumentError if "items" is not a List of the '
      'correct type',
      () async {
        node.params['items'] = ['a', 'b', 'c']; // Invalid type
        expect(
          () => node.run(sharedStorage),
          throwsArgumentError,
          reason: 'Should throw ArgumentError for incorrect list type',
        );
      },
    );

    test(
      'run should throw ArgumentError if "items" parameter is not a List',
      () async {
        node.params['items'] = 123; // Invalid type
        expect(
          () => node.run(sharedStorage),
          throwsArgumentError,
          reason: 'Should throw ArgumentError when items is not a list',
        );
      },
    );

    test('run should handle an empty list of items', () async {
      final items = <int>[];
      node.params['items'] = items;

      final result = await node.run(sharedStorage);

      expect(result, isEmpty, reason: 'Should return an empty list');
      expect(
        node.execCalled,
        isFalse,
        reason: 'exec should not be called for an empty list',
      );
    });

    test('clone should create a new instance with the same properties', () {
      node
        ..name = 'TestIteratingNode'
        ..params['value'] = 123;

      final clonedNode = node.clone();

      expect(clonedNode, isA<MockIteratingBatchNode>());
      expect(clonedNode.name, equals('TestIteratingNode'));
      expect(clonedNode.params['value'], equals(123));
      expect(clonedNode, isNot(same(node)));
    });

    test('run should execute the node and return the result', () async {
      final items = [5, 10];
      node.params['items'] = items;

      final result = await node.run(sharedStorage);

      expect(result, equals([10, 20]));
      expect(node.execCalled, isTrue);
    });

    test('should retrieve items from shared storage if not available in '
        'params', () async {
      final items = [4, 5, 6];
      sharedStorage['items'] = items; // Items are in shared storage

      final result = await node.run(sharedStorage);

      expect(result, equals([8, 10, 12]));
      expect(node.receivedItems, equals(items));
    });

    test(
      'prep should handle a List<dynamic> with correct item types',
      () async {
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.run(sharedStorage);
        expect(result, equals([2, 4, 6]));
      },
    );
  });

  group('Default IteratingBatchNode behavior', () {
    test(
      'should throw UnimplementedError if exec is not implemented',
      () async {
        final node = _UnimplementedIteratingBatchNode();
        node.params['items'] = [1];
        expect(
          () => node.run({}),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}

class _UnimplementedIteratingBatchNode extends IteratingBatchNode<int, int> {
  @override
  _UnimplementedIteratingBatchNode clone() {
    return _UnimplementedIteratingBatchNode();
  }
}
