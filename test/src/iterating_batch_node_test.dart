import 'package:pocketflow/pocketflow.dart';
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
  IteratingBatchNode<int, int> clone() {
    return MockIteratingBatchNode()
      ..name = name
      ..params = Map.from(params);
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
  });
}
