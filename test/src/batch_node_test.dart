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
  });
}
