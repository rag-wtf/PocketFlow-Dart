import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of BatchNode to test its functionalities.
class MockBatchNode extends BatchNode<int, int> {
  bool execCalled = false;
  List<int>? receivedItems;

  @override
  Future<List<int>> exec(List<int> items) async {
    execCalled = true;
    receivedItems = items;
    return items.map((item) => item * 2).toList();
  }

  @override
  BatchNode<int, int> clone() {
    return MockBatchNode()
      ..name = name
      ..params = Map.from(params);
  }
}

void main() {
  group('BatchNode', () {
    late MockBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockBatchNode();
      sharedStorage = {};
    });

    test('run should process a batch of items', () async {
      final items = [1, 2, 3];
      node.params['items'] = items; // Pass items to the node

      final result = await node.run(sharedStorage);

      expect(node.execCalled, isTrue, reason: 'exec should be called');
      expect(
        node.receivedItems,
        equals(items),
        reason: 'exec should receive the list of items',
      );
      expect(
        result,
        equals([2, 4, 6]),
        reason: 'run should return the processed items',
      );
    });

    test(
      'prep should handle a List<dynamic> with correct item types',
      () async {
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.run(sharedStorage);
        expect(result, equals([2, 4, 6]));
      },
    );

    group('prep validation', () {
      test(
        'should throw ArgumentError if "items" parameter is missing',
        () {
          // Intentionally not setting the 'items' parameter
          expect(
            () => node.run(sharedStorage),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'The "items" parameter must be provided.',
              ),
            ),
            reason: 'Should throw ArgumentError when items are null',
          );
        },
      );

      test(
        'should throw ArgumentError if "items" is not a List',
        () {
          node.params['items'] = 123; // Invalid type
          expect(
            () => node.run(sharedStorage),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'The "items" parameter must be a List, but got int.',
              ),
            ),
            reason: 'Should throw ArgumentError when items is not a list',
          );
        },
      );

      test(
        'should throw ArgumentError if "items" has incorrect item types',
        () {
          node.params['items'] = ['a', 'b', 'c']; // Invalid type
          expect(
            () => node.run(sharedStorage),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'The "items" parameter must be a List where all elements are '
                    'of type int.',
              ),
            ),
            reason: 'Should throw ArgumentError for incorrect list type',
          );
        },
      );
    });

    test('clone should create a new instance with the same properties', () {
      node
        ..name = 'TestNode'
        ..params['value'] = 42;

      final clonedNode = node.clone() as MockBatchNode;

      expect(clonedNode, isA<MockBatchNode>());
      expect(clonedNode.name, equals('TestNode'));
      expect(clonedNode.params['value'], equals(42));
      expect(clonedNode, isNot(same(node)));
    });

    test('run should execute the node and return the result', () async {
      final items = [10, 20];
      node.params['items'] = items;

      final result = await node.run(sharedStorage);

      expect(result, equals([20, 40]));
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
  });
}
